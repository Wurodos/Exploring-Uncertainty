extends Node

var good_boys: Array[Slave]
var evil_boys: Array[Slave]

func _ready() -> void:
	randomize()
