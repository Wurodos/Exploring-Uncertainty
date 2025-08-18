extends Node

class_name Game

enum State {Map, Battle, Window, Popup}

const battle_scene = preload("res://scenes/battle.tscn")
const map_scene = preload("res://scenes/map.tscn")

var map_node : Map
var battle_node: Battle


func _ready() -> void:
	
	SignalBus.battle_encounter.connect(_on_battle_encounter)
	SignalBus.end_battle.connect(_on_end_battle)
	SignalBus.play_music.emit("map")
	
	map_node = map_scene.instantiate()
	add_child(map_node)
	
	if CurrentRun.map_data.is_empty():
		map_node.generate_floor()
	else: map_node.generate_from_data(CurrentRun.map_data)
	
	## DEBUG -> Inventory limit
	#for i in range(20):
	#	CurrentRun.inventory.append(ItemPool.fetch("anvil"))
	

func _on_battle_encounter() -> void:
	CurrentRun.state = State.Battle
	
	map_node.visible = false
	$Camera2D.make_current()
	battle_node = battle_scene.instantiate()
	add_child(battle_node)

func _on_end_battle() -> void:
	battle_node.queue_free()
	
	map_node.visible = true
	map_node.camera.make_current()
	SignalBus.play_music.emit("map")
	
	if CurrentRun.state != State.Popup:
		CurrentRun.state = State.Map
