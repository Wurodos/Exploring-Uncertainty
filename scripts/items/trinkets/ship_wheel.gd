extends Item

func localize():
	super.localize()

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.viable_for_vigilance = true

func on_level_up():
	super.on_level_up()
	extra_speed += 1
	extra_hp += level
