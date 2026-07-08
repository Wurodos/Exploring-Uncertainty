extends Item

@export var speed: int = 2
@export var shield: int = 3

func localize():
	super.localize()
	desc = desc.format([speed, shield], "{}")
