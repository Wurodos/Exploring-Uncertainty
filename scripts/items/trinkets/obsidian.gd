extends Item

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.set_luck(+1)
	owner.set_power(+1)
