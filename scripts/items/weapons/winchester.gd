extends Item

@export var first_harm: int = 5
@export var second_harm: int = 3

func localize():
	super.localize()
	desc = desc.format([first_harm, second_harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, first_harm)
	var potential_targets : Array[SlaveNode]
	if sender.team.is_evil:
		potential_targets = \
		Battle.instance.good_team.boys_nodes \
		.filter(func(node : SlaveNode): return node != victim and node.held.is_alive)
	else:
		potential_targets = \
		Battle.instance.evil_team.boys_nodes \
		.filter(func(node : SlaveNode): return node != victim and node.held.is_alive)
	if potential_targets.size() > 0:
		Action.deal_damage(sender, potential_targets.pick_random(), second_harm)

func on_level_up():
	super.on_level_up()
	first_harm += 1
	second_harm += 1

func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return 0

func get_harm() -> int:
	return first_harm+second_harm

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	return Action.calculate_damage(sender, victim, first_harm)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageTwo)
	intention.effect = func(v):
		use_item(sender, v)
	return intention
