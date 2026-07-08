extends Item

@export var harm: int = 7

func localize():
	super.localize()
	desc = desc.format([harm], "{}")
