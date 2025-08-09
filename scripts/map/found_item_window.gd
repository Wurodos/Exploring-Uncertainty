extends Control

func _ready() -> void:
	visible = false
	
	SignalBus.found_item.connect(_on_found_item)


func _on_found_item() -> void:
	visible = true
	CurrentRun.state = Game.State.Window
	var item : Item = ItemPool.fetch_random()
	$Item.texture = item.texture
	CurrentRun.inventory.append(item)


func _on_close_pressed() -> void:
	visible = false
	CurrentRun.state = Game.State.Map
	SignalBus.end_encounter.emit()
