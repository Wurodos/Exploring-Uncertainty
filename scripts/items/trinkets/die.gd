extends Item

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.set_luck(+3)
