extends Node

func _ready() -> void:
	$Label.text = $Label.text.format([tr(CurrentRun.reptile.u_name)], "{}")
