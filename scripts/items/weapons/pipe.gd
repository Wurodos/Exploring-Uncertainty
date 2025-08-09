extends Item

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	if sender.buffs.has("pipe_used"):
		Action.deal_damage(sender, victim, 1)
	else:
		Action.deal_damage(sender, victim, 10)
	sender.buffs.set("pipe_used", 2)
	
