extends Item

func on_start_battle(sender: SlaveNode):
	super.on_start_battle(sender)
	Battle.instance.is_prudence = true

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.vigilance = true

func on_level_up():
	super.on_level_up()
	extra_hp += 5
	if level == 3 or level == 5:
		extra_speed += 1
