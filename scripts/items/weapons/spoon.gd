extends Item

@export var harm: int = 7
@export var heal_percent: int = 1

func localize():
	super.localize()
	desc = desc.format([harm, heal_percent], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	var was_alive = victim.held.is_alive
	Action.deal_damage(sender, victim, harm)
	
	if not sender.team.is_evil and not victim.held.is_alive and was_alive:
		Action.heal(sender, sender, ceil(sender.held.maxhp * float(heal_percent) / 100.0))
	
func on_level_up():
	super.on_level_up()
	harm += 2
	heal_percent += 5

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
