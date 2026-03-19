extends Item

@export var harm: int = 7
@export var health_gain: int = 1

func localize():
	super.localize()
	desc = desc.format([harm,health_gain], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	
	if not victim.held.is_alive and not CurrentRun.is_in_purged:
		sender.set_max_hp(+health_gain)
		sender.set_hp(+health_gain)
		victim.team.cull_the_dead(false, victim)
	else:
		Action.deal_damage(sender, victim, harm)
	
	localize()
	
func on_level_up():
	super.on_level_up()
	harm += 1
	health_gain += 1

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
