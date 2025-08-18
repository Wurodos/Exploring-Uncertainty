extends Node2D

class_name Room

enum Type {Empty, Purged, City, Cherv, Govnov, Reptile, Comms, Any}

var row: int
var col: int
var visited: bool = false
var type: Type

var flag: bool = false

@onready var sprite : Sprite2D = $Sprite

func serialize() -> Dictionary:
	var data = {
		"row": row,
		"col": col,
		"type": type
	}
	if type == Room.Type.City:
		data.merge({
			"visited": visited,
			"flag": flag,
			"heal_used": heal_used,
			"items": items.map(func(item: Item):
				return item.serialize())
		})
	return data

# =======
# only for cities!
# =======

var heal_used: int = 0
var items: Array[Item] = []
