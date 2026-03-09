extends Item

@export var harm: int = 7
@export var multiplier: int = 8

func localize():
	super.localize()
	desc = desc.format([harm, multiplier], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	var origin_crit = Action.crit_multiplier
	Action.crit_multiplier = 8
	Action.deal_damage(sender, victim, harm)
	Action.crit_multiplier = origin_crit
	localize()
	
func on_level_up():
	super.on_level_up()
	harm += 1
	if level >= 3: multiplier += 1

func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return 0

func get_harm() -> int:
	return harm

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	return Action.calculate_damage(sender, victim, harm)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageSingular)
	intention.effect = func(v):
		use_item(sender, v)
	return intention
