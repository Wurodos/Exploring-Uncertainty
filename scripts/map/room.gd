extends Node2D

class_name Room

enum Type {Empty, Purged, City, Cherv, Govnov, Reptile}

var row: int
var col: int
var visited: bool = false
var type: Type

@onready var sprite : Sprite2D = $Sprite

# =======
# only for cities!
# =======

var heal_used: int = 0
var items: Array[Item] = []
