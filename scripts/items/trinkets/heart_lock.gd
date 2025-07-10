extends Item

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.add_buff("shield", 1)
