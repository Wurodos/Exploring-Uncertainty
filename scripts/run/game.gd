extends Node

const battle_scene = preload("res://scenes/battle.tscn")

func _ready() -> void:
	add_child(battle_scene.instantiate())
