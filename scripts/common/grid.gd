extends Control

@export var row_capacity: int

var rows: Array[Node]

func _ready() -> void:
	rows = get_children()

func add_to_grid(node: Node) -> void:
	pass
