extends Node2D
class_name DottedLines

@export var width: float = 4.0
@export var dash: float = 10.0

var to_arr: Array[Vector2] = []
var _color: Color

func redraw_line(to: Array[Vector2], color: Color) -> void:
	to_arr = to
	_color = color
	queue_redraw()

func _draw() -> void:
	for to: Vector2 in to_arr:
		var local = to_local(to)
		var circle_center = local.lerp(Vector2(), 40/local.length())
		
		draw_dashed_line(Vector2(), circle_center, _color, 4.0, 10.0)
		
		var opaque_cl = _color
		opaque_cl.a = 1.0
		draw_circle(circle_center, 10, opaque_cl)
