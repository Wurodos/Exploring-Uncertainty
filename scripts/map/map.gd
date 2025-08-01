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

@export var room_sprites : Dictionary[Room.Type, Texture2D]

const room_prefab = preload("res://prefabs/map/room.tscn")

var current_branch_chance : float
var space_taken : Array[Array] = []
var party_row: int
var party_col: int
var is_encountering: bool = false
var since_last_battle : int = 0

func _ready() -> void:
	$Camera2D.make_current()
	
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
	if room.type != Room.Type.Purged:
		await get_tree().create_timer(0.3).timeout		
	is_encountering = false
	
	encounter(room)
	
	if room.type != Room.Type.City:
		room.type = Room.Type.Purged
		room.sprite.texture = room_sprites[Room.Type.Purged]
	
func encounter(room: Room) -> void:
	match(room.type):
		Room.Type.Empty:
			return
			if since_last_battle >= randi_range(0,3):
				CurrentRun.arrange_evil_team()
				SignalBus.battle_encounter.emit()
				since_last_battle = 0
			since_last_battle = since_last_battle + 1
		Room.Type.City:
			SignalBus.enter_city.emit(room)
		Room.Type.Govnov:
			SignalBus.enter_govnov.emit()
		Room.Type.Cherv:
			since_last_battle = 0
			CurrentRun.arrange_difficult()
			SignalBus.battle_encounter.emit()

func room_at(row: int, col: int) -> Room:
	return room_parent.get_node_or_null(str(row) + "_" + str(col))

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
	for room : Room in room_parent.get_children():
		if room.type != Room.Type.Empty: continue
		
		var r = randf()
		if r < city_rate:
			if not _is_adjacent_to(room.row, room.col, Room.Type.City):
				room.type = Room.Type.City
		elif r < cherv_rate + city_rate:
			if not _is_adjacent_to(room.row, room.col, Room.Type.Cherv):
				room.type = Room.Type.Cherv
		elif r < govnov_rate + cherv_rate + city_rate:
			if not _is_adjacent_to(room.row, room.col, Room.Type.Govnov):
				room.type = Room.Type.Govnov
		room.sprite.texture = room_sprites[room.type]

func _is_adjacent_to(row: int, col: int, type: Room.Type) -> bool:
	for direction in [Direction.Up,
					Direction.Down,
					Direction.Right,
					Direction.Left]:
			var room = room_at(row + _drow[direction], col + _dcol[direction])
			if room and room.type == type: return true
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
