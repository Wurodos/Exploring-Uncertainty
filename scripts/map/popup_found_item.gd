extends Control

func _ready() -> void:
	var item : Item = ItemPool.fetch_random()
	$Item.texture = item.texture
	CurrentRun.put_item_in_inventory(item)

func _on_close_pressed() -> void:
	queue_free()
