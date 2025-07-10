extends Item

func use_item(sender: SlaveNode, ally: SlaveNode):
	ally.set_speed(-3)
