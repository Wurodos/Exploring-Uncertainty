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

@onready var tutorial_box: Control = $Camera2D/UI/TutorialBox
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
@onready var camera : Camera2D = $Camera2D

@export var size: int
@export var branch_chance: float
@export var city_rate: float
@export var cherv_rate: float
@export var govnov_rate: float
@export var comms_rate: float
@export var steps: int


@export var room_sprites : Dictionary[Room.Type, Texture2D]

const room_prefab = preload("res://prefabs/map/room.tscn")

var current_branch_chance : float
var space_taken : Array[Array] = []
var party_row: int
var party_col: int
var is_encountering: bool = false
var since_last_battle : int = 0
var since_last_item: int = 0

static var instance: Map

func _ready() -> void:
	tutorial_box.visible = CurrentRun.is_tutorial
	tutorial_box.get_node("Text").set_string_id("tutorial_map_0")
	
	instance = self
	$Camera2D/UI/ShowTeam.text = tr("brigade")
	
	$Camera2D.make_current()
	$Camera2D/UI/Steps.text = str(steps)
	
	SignalBus.advance_tutorial.connect(_on_tutorial_ok_pressed)
	
	SignalBus.change_steps.connect(func(delta):
		steps += delta
		$Camera2D/UI/Steps.text = str(steps))

func _process(delta: float) -> void:
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
	if not room: return
	
	party_col += _dcol[direction]
	party_row += _drow[direction]
	player_node.global_position = room.global_position
	
	is_encountering = true
	_explore(party_row, party_col)
	
	
	if steps > 0: 
		steps -= 1
		$Camera2D/UI/Steps.text = str(steps)
	else:
		for slave: Slave in CurrentRun.good_boys:
			slave.hp -= 1
		CurrentRun.good_boys = CurrentRun.good_boys.filter(func(slave): return slave.hp > 0)
		SignalBus.refresh.emit()
		if CurrentRun.good_boys.size() == 0:
			get_tree().quit()
	
	
	
	encounter(room)
	if room.type != Room.Type.Purged:
		await get_tree().create_timer(0.6).timeout	
	is_encountering = false	
	
	if room.type != Room.Type.City and room.type != Room.Type.Comms:
		room.type = Room.Type.Purged
		room.sprite.texture = room_sprites[Room.Type.Purged]
	
func encounter(room: Room) -> void:
	SignalBus.entered_room.emit(room)
	match(room.type):
		Room.Type.Empty:
			if since_last_battle >= randi_range(0,6):
				CurrentRun.arrange_evil_team()
				$AnimationPlayer.play("battle_start")
				await $AnimationPlayer.animation_finished
				SignalBus.play_music.emit("battle")
				SignalBus.battle_encounter.emit()
				since_last_battle = 0
				since_last_item += 1
			else: 
				since_last_battle += 1
				print(since_last_item)
				if since_last_item >= randi_range(4, 8):
					SignalBus.found_item.emit()
					since_last_item = 0
				else: since_last_item += 1
		Room.Type.City:
			SignalBus.enter_city.emit(room)
		Room.Type.Govnov:
			SignalBus.enter_govnov.emit()
		Room.Type.Cherv:
			since_last_battle = 0
			CurrentRun.discounts += 1
			CurrentRun.arrange_difficult()
			$AnimationPlayer.play("battle_start")
			await $AnimationPlayer.animation_finished
			SignalBus.play_music.emit("battle_difficult")
			SignalBus.battle_encounter.emit()
		Room.Type.Reptile:
			CurrentRun.arrange_boss()
			$AnimationPlayer.play("battle_start")
			await $AnimationPlayer.animation_finished
			SignalBus.battle_encounter.emit()
		Room.Type.Comms:
			SignalBus.enter_comms.emit(room)
	$AnimationPlayer.play("RESET")

func room_at(row: int, col: int) -> Room:
	return room_parent.get_node_or_null(str(row) + "_" + str(col))

func generate_from_data(data: Dictionary) -> void:
	for i in range(size + 2):
		space_taken.append([])
		for j in range(size + 2):
			space_taken[i].append(false)
	
	since_last_battle = data["since_last_battle"]
	since_last_item = data["since_last_item"]
	
	party_col = data["party_col"]
	party_row = data["party_row"]
	
	steps = data["steps"]
	$Camera2D/UI/Steps.text = str(steps)
	
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
	central_room.type = Room.Type.Purged
	central_room.sprite.texture = room_sprites[Room.Type.Purged]
	
	# Go in every direction
	for direction in [Direction.Up,
					Direction.Down,
					Direction.Right,
					Direction.Left]:
		current_branch_chance = branch_chance
		_go_in_direction(mid + _drow[direction], mid + _dcol[direction],\
		 	direction, randi_range(size/4, size/2))
	
	_add_structures()
	_add_boss()
	_initialize_fog()
	_explore(party_row, party_col)

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
	#print(str(row) + "/" + str(col) + "/" + str(remain))
	if remain == 0 or space_taken[row][col] \
	 	or row < 0 or col < 0 or row > size or col > size: return
	
	
	add_room(row, col)
	
	if randf() < current_branch_chance:
		#print("Branch!")
		current_branch_chance -= 0.02
		var all_dir = [Direction.Up, Direction.Down, Direction.Right, Direction.Left]
		all_dir.erase(direction)
		all_dir.erase(opposite(direction))
		
		var new_dir = all_dir.pick_random()
		#print("Direction: " + str(new_dir))
		var branch_remain = randi_range(size/4, size/2)
		
		_go_in_direction(row + _drow[new_dir], col + _dcol[new_dir], \
		 	new_dir, branch_remain)
	
	_go_in_direction(row + _drow[direction], col + _dcol[direction], \
	 	direction, remain - 1)

# Same structures can't be adjacent

func _add_structures() -> void:
	var all_rooms = room_parent.get_children()
	all_rooms.shuffle()
	
	var city_n = floor(all_rooms.size()*city_rate)
	var cherv_n = floor(all_rooms.size()*cherv_rate)
	var govnov_n = floor(all_rooms.size()*govnov_rate)
	var comms_n = floor(all_rooms.size()*comms_rate)
	
	
	for room : Room in all_rooms:
		if room.type != Room.Type.Empty: continue
		
		if city_n > 0 and not _is_adjacent_to(room.row, room.col, Room.Type.City):
			room.type = Room.Type.City
			city_n -= 1
		elif cherv_n > 0 and not _is_adjacent_to(room.row, room.col, Room.Type.Cherv):
			room.type = Room.Type.Cherv
			cherv_n -= 1
		elif govnov_n > 0 and not _is_adjacent_to(room.row, room.col, Room.Type.Govnov):
			room.type = Room.Type.Govnov
			govnov_n -= 1
		elif comms_n > 0 and not _is_adjacent_to(room.row, room.col, Room.Type.Comms):
			room.type = Room.Type.Comms
			comms_n -= 1
		
		room.sprite.texture = room_sprites[room.type]



func _add_boss() -> void:
	var all_coords: Array[Vector2i] = []
	for row in range(-1, size+2):
		for col in range(-1, size+2):
			if not room_at(row, col) and _is_adjacent_to(row, col, Room.Type.Any):
				if max(abs(row - party_row), abs(col - party_col)) > 4:
					all_coords.append(Vector2i(row, col))
	
	var coords : Vector2i = all_coords.pick_random()
	#for coords in all_coords:
	var room = add_room(coords.x, coords.y)
	room.type = Room.Type.Reptile
	room.sprite.texture = room_sprites[room.type]
		

		
func _is_adjacent_to(row: int, col: int, type: Room.Type) -> bool:
	for direction in [Direction.Up,
					Direction.Down,
					Direction.Right,
					Direction.Left]:
			var room = room_at(row + _drow[direction], col + _dcol[direction])
			if room and (room.type == type or type == Room.Type.Any): return true
	return false

func _initialize_fog() -> void:
	for x in range(-size/2-6, size/2+6):
		for y in range(-size/2-4, size/2+4):
			$World/Fog/TileMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(0,0), 0)

func _explore(row: int, col: int):
	var x = col - size/2
	var y = row - size/2
	
	for i in range(-2, 3):
		for j in range(-2, 3):
			if not (abs(i) == 2 and abs(j) == 2):
				$World/Fog/TileMapLayer.set_cell(Vector2i(x+i,y+j))
	
	
# end

func serialize() -> Dictionary:
	return {
		"rooms": room_parent.get_children().map(func(room: Room):
			return room.serialize()),
		"party_col": party_col,
		"party_row": party_row,
		"since_last_battle": since_last_battle,
		"since_last_item": since_last_item,
		"steps": steps
	}

func _on_save_pressed() -> void:
	CurrentRun.save_game()


func _on_tutorial_ok_pressed() -> void:
	tutorial_progress += 1
	if tutorial_progress == 1:
		tutorial_box.get_node("OK").disabled = true
	elif tutorial_progress == 3:
		tutorial_box.get_node("OK").disabled = false
	
	if tutorial_progress == 4:
		tutorial_box.visible = false
	else:
		tutorial_box.get_node("Text").set_string_id("tutorial_map_"+str(tutorial_progress))
	
