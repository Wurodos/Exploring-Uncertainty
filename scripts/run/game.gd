extends Node

class_name Game

enum State {Map, Battle, Window}

const battle_scene = preload("res://scenes/battle.tscn")
const map_scene = preload("res://scenes/map.tscn")

var map_node : Map
var battle_node: Battle


func _ready() -> void:
	
	SignalBus.battle_encounter.connect(_on_battle_encounter)
	SignalBus.end_battle.connect(_on_end_battle)
	
	CurrentRun.good_boys = [SlavePool.fetch("blob"), SlavePool.fetch("blob"),
	  SlavePool.fetch("blob")
	]
	
	#CurrentRun.good_boys[0].hp = 1
	#CurrentRun.good_boys[1].hp = 1
	#CurrentRun.good_boys[2].hp = 1
	
	map_node = map_scene.instantiate()
	add_child(map_node)
	map_node.generate_floor()
	

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
	CurrentRun.state = State.Map
