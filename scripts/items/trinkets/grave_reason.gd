extends Item

func localize():
	super.localize()

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.tags.append(Action.TAG_HIGH_PRIORITY)

func on_level_up():
	super.on_level_up()
	extra_speed -= 2
