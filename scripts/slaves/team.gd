extends Node

class_name Team

const slave_prefab = preload("res://prefabs/slaves/blob.tscn")

@onready var slave_parents : Array[Node2D] = \
	[$MiddleSlave, $BottomSlave, $TopSlave]

@export var is_evil: bool

var boys: Array[Slave] = []
var boys_nodes: Array[SlaveNode] = []

func _ready() -> void:
	SignalBus.start_battle.connect(_on_start_battle)
	SignalBus.slave_death.connect(_on_slave_death)
	SignalBus.slave_ran.connect(_on_slave_death)

func _on_start_battle() -> void:
	if is_evil: boys.append_array(CurrentRun.evil_boys)
	else: boys.append_array(CurrentRun.good_boys)
	
	var i : int = 0
	for slave in boys:
		var new_slave : SlaveNode = slave_prefab.instantiate()
		new_slave.team = self
		new_slave.apply(slave, is_evil)
		
		boys_nodes.append(new_slave)
		slave_parents[i].add_child(new_slave)
		i += 1

func _on_slave_death(slave_node: SlaveNode) -> void:
	boys.erase(slave_node.held)
