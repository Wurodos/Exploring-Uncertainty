extends Item

@export var value_per_power: int = 7

func localize():
	super.localize()
	desc = desc.format([value_per_power], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	var total = 0;
	for item: Item in owner.get_all_items():
		total += item.cost
	
	owner.set_power(floor(total / value_per_power))

func on_level_up():
	cost += 4
	if level == 3 or level == 5: value_per_power -= 1
	super.on_level_up()
