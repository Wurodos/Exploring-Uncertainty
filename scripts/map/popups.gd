extends Node

const _found_item_prefab = preload("res://prefabs/map/found_item.tscn")
const _lost_item_prefab = preload("res://prefabs/map/lost_item.tscn")
const _message_prefab = preload("res://prefabs/map/message_popup.tscn")

var popup_count: int = 0
var last_state: Game.State

func _ready() -> void:
	SignalBus.found_item.connect(_on_found_item)
	SignalBus.lost_item.connect(_on_lost_item)
	SignalBus.message_popup.connect(_on_message_popup)

func _on_popup_closed():
	popup_count -= 1
	if popup_count == 0:
		CurrentRun.state = last_state

func _on_message_popup(string_id: StringName):
	if CurrentRun.state != Game.State.Popup:
		last_state = CurrentRun.state
	
	CurrentRun.state = Game.State.Popup
	popup_count += 1
	
	var popup = _message_prefab.instantiate()
	add_child(popup)
	popup.apply(string_id)
	popup.tree_exited.connect(_on_popup_closed)

func _on_found_item():
	if CurrentRun.state != Game.State.Popup:
		last_state = CurrentRun.state
	
	CurrentRun.state = Game.State.Popup
	popup_count += 1
	var popup = _found_item_prefab.instantiate()
	add_child(popup)
	popup.tree_exited.connect(_on_popup_closed)

func _on_lost_item(item: Item):
	if CurrentRun.state != Game.State.Popup:
		last_state = CurrentRun.state
	
	CurrentRun.state = Game.State.Popup
	popup_count += 1
	var popup = _lost_item_prefab.instantiate()
	popup.apply(item)
	add_child(popup)
	popup.tree_exited.connect(_on_popup_closed)
