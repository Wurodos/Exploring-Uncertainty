extends Item

@export var turns: int = 1

func localize():
	super.localize()
	desc = desc.format([turns], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.add_buff("shield", turns)

func on_level_up():
	super.on_level_up()
	extra_hp += 3
	if level >= 4: turns += 1
