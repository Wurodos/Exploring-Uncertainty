extends Control

func apply(item: Item) -> void:
	$Item.texture = item.texture

func _on_close_pressed() -> void:
	queue_free()
