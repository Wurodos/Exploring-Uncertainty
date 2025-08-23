extends Node

func apply(string_id: StringName):
	$Label.set_string_id(string_id)

func _on_close_pressed() -> void:
	queue_free()
