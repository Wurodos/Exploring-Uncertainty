extends Item

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	sender.add_buff(Action.SHIELD, 3)
