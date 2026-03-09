extends Node2D

#--------------------------------------------------------------------------------------------------
#----------------------------------------- MAP GENERATION -----------------------------------------
#--------------------------------------------------------------------------------------------------
#
# -- Basic algorithm
# -- Start from center (size/2, size/2)
# -- Create a pool of adjacents
# -- Pick orthogonal direction
# -- Generate random (size / 4 to size / 2) tiles in that dir
# -- At each tile, there's 15% 
#	   (-1% each time it happens)
#	    chance for branch, in which case pick 
#	    perpendicular and add to queue
# -- Repeat those 2 steps until all 4 orthoganal are resolved (w/ branches)

class_name Map

const army_prefab = preload("res://prefabs/map/liberation_army.tscn")

@onready var tutorial_box: Control = $GUI/UI/TutorialBox
var tutorial_progress: int = 0


enum Direction {Up, Down, Right, Left}

func opposite(direction: Direction) -> Direction:
	match(direction):
		Direction.Up: return Direction.Down
		Direction.Down: return Direction.Up
		Direction.Right: return Direction.Left
		Direction.Left: return Direction.Right
	return Direction.Up


const _drow = [-1,+1,0,0]
const _dcol = [0,0,+1,-1]

@onready var room_parent : Node2D = $World/Rooms
@onready var player_node : Node2D = $World/Player
@onready var highlight: TileMapLayer= $World/Highlight/TileMapLayer
@onready var arrow_axis: Node2D = $World/ArrowAxis
@onready var camera : Camera2D = $Camera2D

@export var size: int
@export var branch_chance: float
@export var city_rate: float
@export var cherv_rate: float
@export var govnov_rate: float
@export var comms_rate: float
@export var steps: int
@export var enable_armies: bool = false

@export var room_sprites : Dictionary[Room.Type, Texture2D]

const room_prefab = preload("res://prefabs/map/room.tscn")


var current_branch_chance : float
var space_taken : Array[Array] = []
var party_row: int
var party_col: int
var is_encountering: bool = false
var since_last_battle : int = 0
var since_last_battle_purged: int = 0
var since_last_item: int = 0
var found_items: int = 0

var zone_id: int = 0

#======================
# v EOT stuff v
#======================

var chervs: Array[Room] = []
var elevators: Array[Room] = []
var reptile: Room

#======================
# v Tutorial flags v
#======================
var first_govnov: Room = null
var first_city: Room = null
var first_cherv: Room = null
var first_comms: Room = null
var first_reptile: Room = null

var shown_govnov: bool = false
var shown_city: bool = false
var shown_cherv: bool = false
var shown_comms: bool = false
var shown_reptile: int = 0

var shown_govnov_window: bool = false
var shown_comms_window: bool = false

#======================
# ^ Tutorial flags ^
#======================

static var instance: Map

static func dist(room1: Room, room2: Room) -> int:
	return round(sqrt((room1.row - room2.row) ** 2 + (room1.col - room2.col) ** 2))

func _ready() -> void:
	tutorial_box.visible = CurrentRun.is_tutorial
	tutorial_box.get_node("Text").set_string_id("tutorial_map_0")
	
	instance = self
	$GUI/UI/ShowTeam.text = tr("brigade")
	
	$Camera2D.make_current()
	$GUI/UI/Steps.text = str(steps)
	
	SignalBus.teleport.connect(_teleport)
	SignalBus.advance_tutorial.connect(_on_tutorial_ok_pressed)
	SignalBus.battle_encounter.connect(func(_w: int = 0): $GUI.visible = false)
	SignalBus.change_steps.connect(func(delta):
		steps += delta
		$GUI/UI/Steps.text = str(steps))


func _teleport(to: int) -> void:
	for elevator: Room in elevators:
		if elevator.flag and floor(elevator.data / 10000) == to:
			party_col = elevator.col
			party_row = elevator.row
			player_node.global_position = elevator.global_position
			return


func _process(_delta: float) -> void:
	if CurrentRun.state != Game.State.Map: return
	
	if Input.is_action_just_pressed("party_up"):
		move_player(Direction.Up)
	elif Input.is_action_just_pressed("party_down"):
		move_player(Direction.Down)
	elif Input.is_action_just_pressed("party_left"):
		move_player(Direction.Left)
	elif Input.is_action_just_pressed("party_right"):
		move_player(Direction.Right)
	elif Input.is_action_just_pressed("stay"):
		encounter(room_at(party_row, party_col))

func move_player(direction: Direction) -> void:
	if is_encountering: return
	
	var room: Room = room_at(party_row + _drow[direction], party_col + _dcol[direction])
	if not room:
		return
	if room.type == Room.Type.Reptile and not CurrentRun.is_comms_repaired:
		SignalBus.message_popup.emit("reptile_without_comms")
		return
	
	
	party_col += _dcol[direction]
	party_row += _drow[direction]
	_update_move_buttons()
	player_node.global_position = room.global_position
	
	zone_id = room.area_level
	_explore(party_row, party_col)
	
	
	if steps > 0: 
		steps -= 1
		$GUI/UI/Steps.text = str(steps)
	else:
		for slave: Slave in CurrentRun.good_boys:
			slave.hp -= 1
		CurrentRun.good_boys = CurrentRun.good_boys.filter(func(slave): return slave.hp > 0)
		SignalBus.refresh.emit()
		if CurrentRun.good_boys.size() == 0:
			get_tree().quit()
	
	
	SignalBus.advance_tutorial.emit()
	var adj_cherv = _find_adjacent(room.row, room.col, Room.Type.Cherv)
	if adj_cherv:
		encounter(adj_cherv)
		
		adj_cherv.type = Room.Type.Purged
		adj_cherv.sprite.texture = room_sprites[Room.Type.Purged]
		
		if not _is_adjacent_to(adj_cherv.row+1, adj_cherv.col, Room.Type.Cherv):
			unhighlight(adj_cherv.row+1, adj_cherv.col)
		if not _is_adjacent_to(adj_cherv.row-1, adj_cherv.col, Room.Type.Cherv):
			unhighlight(adj_cherv.row-1, adj_cherv.col)
		if not _is_adjacent_to(adj_cherv.row, adj_cherv.col+1, Room.Type.Cherv):
			unhighlight(adj_cherv.row, adj_cherv.col+1)
		if not _is_adjacent_to(adj_cherv.row, adj_cherv.col-1, Room.Type.Cherv):
			unhighlight(adj_cherv.row, adj_cherv.col-1)
		
		if room.type == Room.Type.Empty:
			purge(room)
	else:
		encounter(room)
		if room.type != Room.Type.City and room.type != Room.Type.Comms and room.type != Room.Type.Elevator:
			purge(room)
	
	end_turn_upkeep()

func purge(room: Room) -> void:
	room.type = Room.Type.Purged
	room.sprite.texture = room_sprites[Room.Type.Purged]
	
func encounter(room: Room) -> void:
	if is_encountering: return
	SignalBus.focus_camera.emit(room.global_position)
	is_encountering = true
	for army: LiberationArmy in $World/Armies.get_children():
		if army.col == party_col and army.row == party_row:
			army.battle()
			await SignalBus.end_battle
			break
	
	SignalBus.entered_room.emit(room)
	
	CurrentRun.is_in_purged = room.type == Room.Type.Purged	
	match(room.type):
		Room.Type.Ruin:
			SignalBus.found_item.emit()
		Room.Type.Purged:
			if since_last_battle_purged >= randi_range(12, 20):
				CurrentRun.evil_boys = CurrentRun.arrange_evil_team(zone_id)
				$AnimationPlayer.play("battle_start")
				await $AnimationPlayer.animation_finished
				SignalBus.play_music.emit("battle")
				SignalBus.battle_encounter.emit()
				since_last_battle_purged = 0
				since_last_battle = 0
			else: since_last_battle_purged += 1
		Room.Type.Empty:
			if since_last_battle >= randi_range(4,8):
				CurrentRun.evil_boys = CurrentRun.arrange_evil_team(zone_id)
				$AnimationPlayer.play("battle_start")
				await $AnimationPlayer.animation_finished
				SignalBus.play_music.emit("battle")
				SignalBus.battle_encounter.emit()
				since_last_battle = 0
				since_last_item += 1
			else: 
				since_last_battle += 1
				if since_last_item >= randi_range(4, 8*(found_items+1)):
					found_items += 1
					SignalBus.found_item.emit()
					since_last_item = 0
				else: since_last_item += 1
		Room.Type.City:
			SignalBus.enter_city.emit(room)
		Room.Type.Govnov:
			if CurrentRun.is_tutorial and not shown_govnov_window:
				shown_govnov_window = true
				SignalBus.advance_tutorial.emit("tutorial_govnov_window")
			SignalBus.enter_govnov.emit()
		Room.Type.Cherv:
			since_last_battle = 0
			CurrentRun.discounts += 1
			CurrentRun.evil_boys = CurrentRun.arrange_evil_team(zone_id)
			$AnimationPlayer.play("battle_start")
			await $AnimationPlayer.animation_finished
			
			if CurrentRun.is_tutorial:
				shown_comms_window = true
				SignalBus.advance_tutorial.emit("tutorial_cherv_won")
				
			SignalBus.play_music.emit("battle_difficult")
			if zone_id < 2:
				SignalBus.battle_encounter.emit(2)
			else: SignalBus.battle_encounter.emit(3)
		Room.Type.Reptile:
			CurrentRun.arrange_boss()
			$AnimationPlayer.play("battle_start")
			await $AnimationPlayer.animation_finished
			SignalBus.play_music.emit("roots_and_toots")
			SignalBus.battle_encounter.emit()
		Room.Type.Comms:
			if CurrentRun.is_tutorial and not shown_comms_window:
				shown_comms_window = true
				SignalBus.advance_tutorial.emit("tutorial_comms_window")
			SignalBus.enter_comms.emit(room)
		Room.Type.Elevator:
			#TODO TUTORIAL
			#if CurrentRun.is_tutorial and not shown_comms_window:
			#	shown_comms_window = true
			#	SignalBus.advance_tutorial.emit("tutorial_comms_window")
			SignalBus.enter_elevator.emit(room)
	$AnimationPlayer.play("RESET")
	is_encountering = false

func unhighlight(row: int, col: int) -> void:
	var x = col - size/2
	var y = row - size/2
	highlight.set_cell(Vector2i(x,y), -1)

func end_turn_upkeep():
	
	
	if not enable_armies: return
	#if $World/Armies.get_child_count() == 0:
	#	var army: LiberationArmy = army_prefab.instantiate()
	#	$World/Armies.add_child(army)
	#	army.col = party_col+1
	#	army.row = party_row
	#	army.position = room_at(army.row, army.col).position
	#
	for army: LiberationArmy in $World/Armies.get_children():
		army.move()
		if army.col == party_col and army.row == party_row:
			army.battle()
			await SignalBus.end_battle
	
	for cherv : Room in chervs:
		cherv.data -= 1
		if cherv.data == 0:
			var army: LiberationArmy = army_prefab.instantiate()
			$World/Armies.add_child(army)
			army.col = cherv.col
			army.row = cherv.row
			army.position = cherv.position
			army.make_path()
			
			cherv.data = 25


func room_at(row: int, col: int) -> Room:
	return room_parent.get_node_or_null(str(row) + "_" + str(col))

func generate_from_data(data: Dictionary) -> void:
	for i in range(size + 2):
		space_taken.append([])
		for j in range(size + 2):
			space_taken[i].append(false)
	
	since_last_battle = data["since_last_battle"]
	since_last_item = data["since_last_item"]
	since_last_battle_purged = data["since_last_battle_purged"]
	found_items = data["found_items"]
	
	party_col = data["party_col"]
	party_row = data["party_row"]
	
	steps = data["steps"]
	$GUI/UI/Steps.text = str(steps)
	
	_initialize_fog()
	
	for room_data in data["rooms"]:
		var room: Room = add_room(room_data["row"], room_data["col"])
		room.type = floor(room_data["type"])
		room.sprite.texture = room_sprites[room.type]
		
		if room.type == Room.Type.City:
			room.visited = room_data["visited"]
			if room.visited: _explore(room.row, room.col)
			
			room.flag = room_data["flag"]
			if room.flag: room.sprite.texture = Gallery.img_free_city
			
			room.heal_used = room_data["heal_used"]
			
			for item_data: Dictionary in room_data["items"]:
				room.items.append(Item.deserialize(item_data))
		elif room.type == Room.Type.Comms:
			room.visited = room_data["visited"]
			if room.visited: _explore(room.row, room.col)
			
			room.flag = room_data["flag"]
			
			room.heal_used = room_data["message_id"]
			if room.flag:
				CurrentRun.messages_not_seen.erase(room.heal_used)
			
			room.data = room_data["data"]
		elif room.type == Room.Type.Purged:
			_explore(room.row, room.col)
		
	_explore(party_row, party_col)
	player_node.global_position = room_at(party_row, party_col).global_position

func generate_floor() -> void:
	
	for i in range(size + 2):
		space_taken.append([])
		for j in range(size + 2):
			space_taken[i].append(false)
	
	var mid : int = size/2
	
	party_col = mid
	party_row = mid
	
	# Add central room
	var central_room = add_room(mid, mid)
	central_room.type = Room.Type.Elevator
	central_room.sprite.texture = room_sprites[Room.Type.Elevator]
	elevators.append(central_room)
	
	# Go in every direction
	for direction in [Direction.Up,
					Direction.Down,
					Direction.Right,
					Direction.Left]:
		current_branch_chance = branch_chance
		_go_in_direction(mid + _drow[direction], mid + _dcol[direction],\
		 	direction, randi_range(size/4, size/2))
	
	_divide_by_area()
	_add_boss()
	_initialize_fog()
	_explore(party_row, party_col)
	_update_move_buttons()

func add_room(row: int, col: int) -> Room:
	var room_node : Room = room_prefab.instantiate()
	room_parent.add_child(room_node)
	room_node.row = row
	room_node.col = col
	room_node.type = Room.Type.Empty
	room_node.name = str(row) + "_" + str(col)
	
	space_taken[row][col] = true
	
	room_node.position = Vector2((col - size/2)*128, (row - size/2)*128)
	return room_node

func _go_in_direction(row: int, col: int, direction : Direction, remain: int):
	if remain == 0 or space_taken[row][col] \
	 	or row < 0 or col < 0 or row > size or col > size: return
	
	
	add_room(row, col)
	
	if randf() < current_branch_chance:
		current_branch_chance -= 0.02
		var all_dir = [Direction.Up, Direction.Down, Direction.Right, Direction.Left]
		all_dir.erase(direction)
		all_dir.erase(opposite(direction))
		
		var new_dir = all_dir.pick_random()
		var branch_remain = randi_range(size/4, size/2)
		
		_go_in_direction(row + _drow[new_dir], col + _dcol[new_dir], \
		 	new_dir, branch_remain)
	
	_go_in_direction(row + _drow[direction], col + _dcol[direction], \
	 	direction, remain - 1)

# Same structures can't be adjacent

func _add_structures(all_rooms: Array[Room], area_id: int) -> void:
	all_rooms.shuffle()
	
	var city_n = floor(all_rooms.size()*city_rate)
	var cherv_n = floor(all_rooms.size()*cherv_rate)
	var govnov_n = floor(all_rooms.size()*govnov_rate)
	var comms_n = floor(all_rooms.size()*comms_rate)
	if area_id == 0: comms_n = 0
	var elevator_n = 0
	if area_id > 0 and area_id < 4:
		elevator_n = 3
	
	var cherv_i = 1
	var start_room: Room = room_at(party_row, party_col)
	
	for room : Room in all_rooms:
		if room.type != Room.Type.Empty: continue
		
		if city_n > 0 and not _is_adjacent_to(room.row, room.col, Room.Type.City):
			room.type = Room.Type.City
			city_n -= 1
		elif cherv_n > 0 and not _is_adjacent_to(room.row, room.col, Room.Type.Cherv) and dist(room, start_room) > 1:
			room.type = Room.Type.Cherv
			room.data = cherv_i * 5
			chervs.append(room)
			cherv_i += 1
			cherv_n -= 1
			
			var x = room.col - size/2
			var y = room.row - size/2
			if room_at(room.row+1, room.col): highlight.set_cell(Vector2i(x,y+1), 2, Vector2i(0,0), 0)
			if room_at(room.row, room.col+1): highlight.set_cell(Vector2i(x+1,y), 2, Vector2i(0,0), 0)
			if room_at(room.row, room.col-1): highlight.set_cell(Vector2i(x-1,y), 2, Vector2i(0,0), 0)
			if room_at(room.row-1, room.col): highlight.set_cell(Vector2i(x,y-1), 2, Vector2i(0,0), 0)
		elif govnov_n > 0 and not _is_adjacent_to(room.row, room.col, Room.Type.Govnov):
			room.type = Room.Type.Govnov
			govnov_n -= 1
		elif comms_n > 0 and not _is_adjacent_to(room.row, room.col, Room.Type.Comms):
			room.type = Room.Type.Comms
			comms_n -= 1
		elif elevator_n > 0:
			var valid = true
			for elevator: Room in elevators:
				if dist(elevator, room) < 5:
					valid = false
					break
			
			if valid:
				room.type = Room.Type.Elevator
				elevators.append(room)
				elevator_n -= 1
		
		room.sprite.texture = room_sprites[room.type]



func _add_boss() -> void:
	var all_coords: Array[Vector2i] = []
	for row in range(-1, size+2):
		for col in range(-1, size+2):
			if not room_at(row, col) and _is_adjacent_to(row, col, Room.Type.Any):
				if max(abs(row - party_row), abs(col - party_col)) > 8:
					all_coords.append(Vector2i(row, col))
	
	var coords : Vector2i = all_coords.pick_random()
	var room = add_room(coords.x, coords.y)
	room.type = Room.Type.Reptile
	room.sprite.texture = room_sprites[room.type]
	
	reptile = room
		
func _divide_by_area() -> void:
	var start_room: Room = room_at(party_row, party_col)
	var area_0: Array[Room] = []
	var area_1: Array[Room] = []
	var area_2: Array[Room] = []
	var area_3: Array[Room] = []
	var area_4: Array[Room] = []
	for room: Room in room_parent.get_children():
		if dist(room, start_room) > 16:
			room.modulate = Color.INDIAN_RED
			room.area_level = 4
			area_4.append(room)
		elif dist(room, start_room) > 12:
			room.modulate = Color.SLATE_GRAY
			room.area_level = 3
			area_3.append(room)
		elif dist(room, start_room) > 7:
			room.modulate = Color.GREEN_YELLOW
			room.area_level = 2
			area_2.append(room)
		elif dist(room, start_room) > 3:
			room.modulate = Color.BURLYWOOD
			room.area_level = 1
			area_1.append(room)
		else:
			area_0.append(room)
	_add_structures(area_0, 0)
	_add_structures(area_1, 1)
	_add_structures(area_2, 2)
	_add_structures(area_3, 3)
	_add_structures(area_4, 4)
		
			
func _is_adjacent_to(row: int, col: int, type: Room.Type) -> bool:
	for direction in [Direction.Up,
					Direction.Down,
					Direction.Right,
					Direction.Left]:
			var room = room_at(row + _drow[direction], col + _dcol[direction])
			if room and (room.type == type or type == Room.Type.Any): return true
	return false

func _find_adjacent(row: int, col: int, type: Room.Type) -> Room:
	for direction in [Direction.Up,
					Direction.Down,
					Direction.Right,
					Direction.Left]:
			var room = room_at(row + _drow[direction], col + _dcol[direction])
			if room and (room.type == type or type == Room.Type.Any): return room
	return null

func _initialize_fog() -> void:
	for x in range(-size/2-12, size/2+12):
		for y in range(-size/2-6, size/2+7):
			$World/Fog/TileMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(0,0), 0)

func _explore(row: int, col: int):
	var x = col - size/2
	var y = row - size/2
	
	for i in range(-2, 3):
		for j in range(-2, 3):
			if not (abs(i) == 2 and abs(j) == 2):
				var room : Room = room_at(row+i, col+j)
				
				if room and CurrentRun.is_tutorial:
					match(room.type):
						Room.Type.Govnov: first_govnov = room
						Room.Type.City: first_city = room
						Room.Type.Cherv: first_cherv = room
						Room.Type.Reptile: first_reptile = room
						Room.Type.Comms: first_comms = room
				
				$World/Fog/TileMapLayer.set_cell(Vector2i(x+i,y+j))
	
	
# Misc:

func serialize() -> Dictionary:
	return {
		"rooms": room_parent.get_children().map(func(room: Room):
			return room.serialize()),
		"party_col": party_col,
		"party_row": party_row,
		"since_last_battle": since_last_battle,
		"since_last_battle_purged": since_last_battle_purged,
		"since_last_item": since_last_item,
		"found_items": found_items,
		"steps": steps
	}

func _on_save_pressed() -> void:
	CurrentRun.save_game()


func _on_tutorial_ok_pressed(specific_id: StringName = "") -> void:
	if specific_id.length() > 0:
		tutorial_box.visible = true
		tutorial_box.get_node("OK").disabled = false
		tutorial_box.get_node("Text").set_string_id(specific_id)
		return
	
	if CurrentRun.state == Game.State.Battle: return
	
	tutorial_progress += 1
	if tutorial_progress == 1:
		tutorial_box.get_node("OK").disabled = true
	elif tutorial_progress == 3:
		tutorial_box.get_node("OK").disabled = false
	
	if tutorial_progress >= 4:
		tutorial_box.visible = true
		if shown_reptile <= 3 and first_reptile:
			arrow_axis.visible = true
			arrow_axis.global_position = first_reptile.global_position
			tutorial_box.get_node("Text").set_string_id("tutorial_reptile_meet_"+str(shown_reptile))
			shown_reptile += 1
		elif not shown_comms and first_comms:
			shown_comms = true
			arrow_axis.visible = true
			arrow_axis.global_position = first_comms.global_position
			tutorial_box.get_node("Text").set_string_id("tutorial_comms_meet")
		elif not shown_city and first_city:
			shown_city = true
			arrow_axis.visible = true
			arrow_axis.global_position = first_city.global_position
			tutorial_box.get_node("Text").set_string_id("tutorial_city_meet")
		elif not shown_cherv and first_cherv:
			shown_cherv = true
			arrow_axis.visible = true
			arrow_axis.global_position = first_cherv.global_position
			tutorial_box.get_node("Text").set_string_id("tutorial_cherv_meet")
		elif not shown_govnov and first_govnov:
			shown_govnov = true
			arrow_axis.visible = true
			arrow_axis.global_position = first_govnov.global_position
			tutorial_box.get_node("Text").set_string_id("tutorial_govnov_meet")
		else:
			arrow_axis.visible = false
			tutorial_box.visible = false
	else:
		tutorial_box.get_node("Text").set_string_id("tutorial_map_"+str(tutorial_progress))


	
func _update_move_buttons() -> void:
	$World/Player/Down.visible = is_instance_valid(room_at(party_row+1, party_col))
	$World/Player/Up.visible = is_instance_valid(room_at(party_row-1, party_col))
	$World/Player/Right.visible = is_instance_valid(room_at(party_row, party_col+1))
	$World/Player/Left.visible = is_instance_valid(room_at(party_row, party_col-1))

func _on_left_pressed() -> void:
	move_player(Direction.Left)


func _on_right_pressed() -> void:
	move_player(Direction.Right)


func _on_up_pressed() -> void:
	move_player(Direction.Up)


func _on_down_pressed() -> void:
	move_player(Direction.Down)


func _on_stay_pressed() -> void:
	encounter(room_at(party_row, party_col))
