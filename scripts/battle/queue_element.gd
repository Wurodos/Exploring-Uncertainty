extends ColorRect

class_name QueueElement

var _color: Color

func apply(slave: Slave):
	$Body.texture = slave.texture
	if slave.is_evil: _color = Color.RED
	else: _color = Color.BLUE
	color = _color

func toggle_select(active: bool):
	if active: color = Color.YELLOW
	else: color = _color
