extends Node

const battle_scene = preload("res://scenes/battle.tscn")
const map_scene = preload("res://scenes/map.tscn")

func _ready() -> void:
	CurrentRun.good_boys = [SlavePool.fetch("blob"), SlavePool.fetch("blob"), SlavePool.fetch("blob")]
	CurrentRun.evil_boys = [SlavePool.fetch("cherv"), SlavePool.fetch("cherv")]
	CurrentRun.good_boys[0].equip(ItemPool.fetch("crown"))
	CurrentRun.good_boys[0].equip(ItemPool.fetch("heart_lock"))
	CurrentRun.good_boys[1].equip(ItemPool.fetch("die"), 2)
	CurrentRun.good_boys[1].equip(ItemPool.fetch("pipe"))
	CurrentRun.good_boys[1].equip(ItemPool.fetch("alcohol"))
	
	add_child(map_scene.instantiate())
	#add_child(battle_scene.instantiate())
	
