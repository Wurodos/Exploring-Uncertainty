extends Item

@export var harm: int = 7
@export var percent: int = 7

func localize():
	super.localize()
	desc = desc.format([harm, percent], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	var was_alive = victim.held.is_alive
	Action.deal_damage(sender, victim, harm)
	
	if not CurrentRun.is_in_purged and not sender.team.is_evil and not victim.held.is_alive and was_alive:
		sender.set_power(+ceil(victim.held.maxhp * percent / 100.0))
	
func on_level_up():
	super.on_level_up()
	harm += 2
	percent += 5 * (level - 1)

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
