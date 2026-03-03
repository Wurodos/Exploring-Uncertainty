extends Node2D
class_name LiberationArmy

@warning_ignore_start("shadowed_variable")

class PathNode:
	var row: int
	var col: int
	var prev: PathNode
	
	func _init(row: int, col: int) -> void:
		self.row = row
		self.col = col
		self.prev = null
	
	

var row : int
var col : int

var path : Array[PathNode] = []


func _ready() -> void:
	var i = 0
	for sprite: Sprite2D in $Sprites.get_children():
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "position", sprite.position + Vector2(0,-15), 0.25).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(sprite, "position", sprite.position, 0.25).set_trans(Tween.TRANS_QUAD)
		tween.set_loops()
		tween.stop()
		get_tree().create_timer(i * 0.1).timeout.connect(func(): tween.play())
		i += 1


func move() -> void:
	var node : PathNode = path.pop_back()
	row = node.row
	col = node.col
	var room: Room = Map.instance.room_at(row, col)
	global_position = room.global_position
	if room.type == Room.Type.City:
		room.type = Room.Type.Ruin
		room.sprite.texture = Map.instance.room_sprites[Room.Type.Ruin]
		
	if path.is_empty(): make_path()

func battle() -> void:
	#CurrentRun.arrange_evil_team()
	SignalBus.play_music.emit("battle")
	SignalBus.battle_encounter.emit()
	queue_free()


func make_path() -> void:
	var target : PathNode = _bfs()
	
	while target.prev != null:
		path.append(target)
		target = target.prev

# ====================
# v   PATHFINDING    v
# ====================

func _bfs() -> PathNode:
	var explored: Array[Array] = []
	for i in range(Map.instance.size + 2):
		explored.append([])
		for j in range(Map.instance.size + 2):
			explored[i].append(false) 
	
	explored[row][col] = true
	
	var q : Array[PathNode] = []
	q.append(PathNode.new(row, col))
	
	while !q.is_empty():
		var v : PathNode = q.pop_front()
		if Map.instance.room_at(v.row, v.col).type == Room.Type.City:
			return v
		for neighbor: PathNode in _get_neighbors(v.row, v.col):
			if !explored[neighbor.row][neighbor.col]:
				explored[neighbor.row][neighbor.col] = true
				neighbor.prev = v
				q.append(neighbor)
		
	return null

func _get_neighbors(row: int, col: int) -> Array[PathNode]:
	var result: Array[PathNode] = []
	if Map.instance.space_taken[row+1][col]: result.append(PathNode.new(row+1, col))
	if Map.instance.space_taken[row][col+1]: result.append(PathNode.new(row, col+1))
	if Map.instance.space_taken[row-1][col]: result.append(PathNode.new(row-1, col))
	if Map.instance.space_taken[row][col-1]: result.append(PathNode.new(row, col-1))
	return result







# --
