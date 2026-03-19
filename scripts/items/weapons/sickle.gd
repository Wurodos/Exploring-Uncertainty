extends Item

@export var harm: int = 3
@export var multiplier: int = 3

func localize():
	super.localize()
	desc = desc.format([harm, multiplier], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	if victim.held.maxhp == victim.held.hp:
		Action.damage_multiplier = multiplier
	Action.deal_damage(sender, victim, harm)
	Action.damage_multiplier = 1

func on_level_up():
	super.on_level_up()
	harm += 1
	if level >= 4: multiplier += 1

func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return 0

func get_harm() -> int:
	return harm*Battle.instance.good_team.boys.size()

func get_displayed_harm(sender: SlaveNode, _victim: SlaveNode) -> int:
	return Action.calculate_damage(sender, null, harm)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageMultiple)
	intention.effect = func(v):
		use_item(sender, v)
	for i in range(Battle.instance.good_team.boys_nodes.size()):
		intention.targets.append(i)
	return intention
