extends Item

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.add_buff(Action.SHIELD, 1)

func on_level_up():
	extra_hp += 1
	extra_speed += 1
	super.on_level_up()
