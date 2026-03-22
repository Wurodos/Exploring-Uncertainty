extends Item

@export var static_stat: int = 5

func localize():
	super.localize()
	desc = desc.format([static_stat], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.set_static(+static_stat)

func on_level_up():
	super.on_level_up()
	static_stat += 5
