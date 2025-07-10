extends Item

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.add_buff(Action.SHIELD, 1)
