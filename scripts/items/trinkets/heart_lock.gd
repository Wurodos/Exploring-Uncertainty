extends Item

@export var turns: int = 1

func localize():
	super.localize()
	desc = desc.format([turns], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.add_buff("shield", turns)
