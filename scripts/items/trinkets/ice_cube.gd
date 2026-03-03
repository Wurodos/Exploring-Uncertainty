extends Item

var sender: SlaveNode

func localize():
	super.localize()

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.attacked.connect(_freeze)
	sender = owner

func _freeze(victim: SlaveNode):
	victim.add_buff(Action.FREEZE, 1)

func on_level_up():
	super.on_level_up()
	extra_speed += 1
