extends Item

var sender: SlaveNode

func localize():
	super.localize()

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.attacked.connect(_freeze)
	sender = owner

func on_unequip_battle(owner: SlaveNode):
	super.on_unequip_battle(owner)
	owner.attacked.disconnect(_freeze)

func on_equip_battle(owner: SlaveNode):
	super.on_equip_battle(owner)
	sender = owner
	owner.attacked.connect(_freeze)

func _freeze(victim: SlaveNode):
	victim.add_buff(Action.FREEZE, 1)

func on_level_up():
	super.on_level_up()
	extra_speed += 1
