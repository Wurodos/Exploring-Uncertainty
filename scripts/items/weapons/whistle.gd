extends Item

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, 3)
