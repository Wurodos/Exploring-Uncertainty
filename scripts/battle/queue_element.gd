extends ColorRect

class_name QueueElement

var _color: Color
var held: Slave

func apply(slave: Slave):
	$Body.texture = slave.texture
	if slave.is_evil: _color = Color.RED
	else: _color = Color.BLUE
	held = slave
	color = _color

func toggle_select(active: bool):
	if active: color = Color.YELLOW
	else: color = _color


func _on_body_mouse_entered() -> void:
	SignalBus.speed_queue_mouse_entered.emit(held)


func _on_body_mouse_exited() -> void:
	SignalBus.speed_queue_mouse_exit.emit(held)
