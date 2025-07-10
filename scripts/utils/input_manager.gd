extends Node

var screen_size : Vector2 

func _ready() -> void:
	screen_size = Vector2(get_viewport().get_window().size)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		SignalBus.mouse_dragged.emit(event.position - screen_size*0.5)
	
	if event is InputEventMouseButton:
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				SignalBus.mouse_up.emit()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				SignalBus.mouse_right_up.emit()
		else:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				SignalBus.mouse_right_down.emit()
