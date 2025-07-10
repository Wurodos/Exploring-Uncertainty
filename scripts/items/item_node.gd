extends Node2D

class_name ItemNode

var held : Item
var sprite: Sprite2D

func apply(item: Item, is_flipped: bool = false):
	held = item
	
	sprite = $Sprite
	sprite.flip_h = is_flipped
	sprite.texture = item.texture
