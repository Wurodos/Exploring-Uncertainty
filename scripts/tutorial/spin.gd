extends Node

@export var radius: float = 0
@export var speed: float = 0

var angle_delta: float
var angle: float

func _ready() -> void:
	angle_delta = 2.0*PI / get_child_count()
	angle = 0.0
	for child: Control in get_children():
		child.position = Vector2(radius * cos(angle), radius * sin(angle))
		angle += angle_delta
	

func _process(delta: float) -> void:
	angle += delta * speed
	var current: float = angle
	for child: Control in get_children():
		child.position = Vector2(radius * cos(current), radius * sin(current))
		current += angle_delta
