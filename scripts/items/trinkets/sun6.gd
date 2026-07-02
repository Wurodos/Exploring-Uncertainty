extends Item

func localize():
	super.localize()

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.tags.append(Action.TAG_LOW_PRIORITY)

func on_unequip_battle(owner: SlaveNode):
	super.on_unequip_battle(owner)
	owner.tags.erase(Action.TAG_LOW_PRIORITY)

func on_equip_battle(owner: SlaveNode):
	super.on_equip_battle(owner)
	owner.tags.append(Action.TAG_LOW_PRIORITY)

func on_level_up():
	super.on_level_up()
	cost += 6
