extends Control

class_name Grid

@export var row_capacity: int

var node_count : int = 0
var rows: Array[Node]

func _ready() -> void:
	rows = get_children()

func add_to_grid(node: Node) -> void:
	get_child(node_count / row_capacity).add_child(node)
	node.tree_exited.connect(_child_removed)
	node_count += 1

func clear() -> void:
	for row : Node in get_children():
		for child : Node in row.get_children():
			child.free()

func _child_removed() -> void:
	node_count -= 1
