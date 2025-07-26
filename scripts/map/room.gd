extends Node2D

class_name Room

enum Type {Empty, Purged, City, Cherv, Govnov, Reptile}

var row: int
var col: int
var type: Type

@onready var sprite : Sprite2D = $Sprite
