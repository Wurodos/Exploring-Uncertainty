extends Item

@export var power_gain: int = 1
@export var luck_gain: int = 1

func localize():
	super.localize()
	desc = desc.format([power_gain, luck_gain], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.set_power(+power_gain)
	owner.set_luck(+luck_gain)
	
