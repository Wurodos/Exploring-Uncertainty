extends TextureRect

@export var hover_modulate: Color = Color.WHITE

signal pressed

var default_modulate: Color = Color.WHITE

func _ready() -> void:
	default_modulate = self_modulate

func _emit() -> void:
	pressed.emit()


func _on_button_mouse_entered() -> void:
	self_modulate = hover_modulate


func _on_button_mouse_exited() -> void:
	self_modulate = default_modulate
