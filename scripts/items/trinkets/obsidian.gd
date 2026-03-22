extends Item

@export var power_gain: int = 1
@export var luck_gain: int = 1
@export var static_gain: int = 1

func localize():
	super.localize()
	desc = desc.format([power_gain, luck_gain, static_gain], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.set_power(+power_gain)
	owner.set_luck(+luck_gain)
	owner.set_static(+static_gain)
	
func on_level_up():
	super.on_level_up()
	extra_hp += 1
	extra_speed += 1
	power_gain += 1
	luck_gain += 1
	static_gain += 1
