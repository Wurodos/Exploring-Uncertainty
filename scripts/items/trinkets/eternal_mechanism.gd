extends Item

func localize():
	super.localize()

func on_end_battle(owner: Slave):
	var possible: Array[Item] = []
	possible = owner.get_all_items().filter(func(item: Item): return item.is_item() and item.level < 5 and item != self)
	if not possible.is_empty():
		var item: Item = possible.pick_random()
		for i in range(item.level, 5):
			item.level_up(owner)

func on_level_up():
	super.on_level_up()
	extra_speed += level - 1
