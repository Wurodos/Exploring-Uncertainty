extends Item

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	
	var dmg = 2 + max(0, 2 * (sender.held.speed - victim.held.speed))
	Action.deal_damage(sender, victim, dmg)
