extends Item

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, 5)
	var potential_targets : Array[SlaveNode] = \
		Battle.instance.evil_team.boys_nodes \
		.filter(func(node : SlaveNode): return node != victim and node.held.is_alive)
	if potential_targets.size() > 0:
		Action.deal_damage(sender, potential_targets.pick_random(), 3)
