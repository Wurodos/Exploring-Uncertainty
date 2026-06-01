extends Node

class_name Game

enum State {Map, Battle, Window, Popup, Phone}

const battle_scene = preload("res://scenes/battle.tscn")
const map_scene = preload("res://scenes/map.tscn")

var map_node : Map
var battle_node: Battle

var map_music_id: int = 1


func _ready() -> void:
	SignalBus.battle_encounter.connect(_on_battle_encounter)
	SignalBus.end_battle.connect(_on_end_battle)
	SignalBus.play_music.emit("map_1")
	
	map_node = map_scene.instantiate()
	add_child(map_node)
	
	if CurrentRun.map_data.is_empty():
		map_node.generate_floor()
	else: map_node.generate_from_data(CurrentRun.map_data)
	
	for item: Item in ItemPool._pool.values():
		if item.is_item():
			CurrentRun.craft_pool.append(item.duplicate())
	

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
	
	map_music_id += 1
	if map_music_id > 3: map_music_id = 1
	
	SignalBus.play_music.emit("map_"+str(map_music_id))
	
	if CurrentRun.state != State.Popup:
		CurrentRun.state = State.Map
