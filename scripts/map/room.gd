extends Node2D

class_name Room

enum Type {Empty, Purged, City, Cherv, Govnov, Reptile, Any}

var row: int
var col: int
var visited: bool = false
var type: Type

var flag: bool = false

@onready var sprite : Sprite2D = $Sprite

# =======
# only for cities!
# =======

var heal_used: int = 0
var items: Array[Item] = []
