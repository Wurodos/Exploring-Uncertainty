extends Item

@export var first_harm: int = 5
@export var second_harm: int = 3

func localize():
	super.localize()
	desc = desc.format([first_harm, second_harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, first_harm)
	var potential_targets : Array[SlaveNode] = \
		Battle.instance.evil_team.boys_nodes \
		.filter(func(node : SlaveNode): return node != victim and node.held.is_alive)
	if potential_targets.size() > 0:
		Action.deal_damage(sender, potential_targets.pick_random(), second_harm)
