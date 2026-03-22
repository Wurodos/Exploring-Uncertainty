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
	
	for item: Item in ItemPool._pool.values():
		if item.is_item():
			CurrentRun.craft_pool.append(item.duplicate())

	## DEBUG -> Inventory 
	#CurrentRun.craft_recipes.append(ItemPool.fetch("regime_change"))
	#CurrentRun.inventory.append(ItemPool.fetch("generator"))
	#CurrentRun.inventory.append(ItemPool.fetch("regime_change"))
	#CurrentRun.inventory.append(ItemPool.fetch("wire"))
	#CurrentRun.inventory.append(ItemPool.fetch("bomb"))
	#CurrentRun.inventory.back().on_level_up()
	#CurrentRun.inventory.append(ItemPool.fetch("ice_cube"))
	#CurrentRun.inventory.back().on_level_up()
	#CurrentRun.inventory.append(ItemPool.fetch("shot_shells"))
	#for i in range(20):
	#	CurrentRun.inventory.append(ItemPool.fetch_random())
	

func _on_battle_encounter(wave_count: int = 1) -> void:
	CurrentRun.state = State.Battle
	
	map_node.visible = false
	$Camera2D.make_current()
	battle_node = battle_scene.instantiate()
	add_child(battle_node)
	battle_node.wave_count = wave_count

func _on_end_battle() -> void:
	battle_node.queue_free()
	
	map_node.visible = true
	map_node.camera.make_current()
	map_node.get_node("GUI").visible = true
	SignalBus.play_music.emit("map")
	
	if CurrentRun.state != State.Popup:
		CurrentRun.state = State.Map
