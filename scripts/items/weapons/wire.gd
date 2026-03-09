extends Item

@export var harm: int = 7
@export var harm_per_static: int = 0

func localize():
	super.localize()
	desc = desc.format([harm, harm_per_static], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)
	if sender.static_stat > 0:
		for slave in victim.team.boys_nodes:
			if slave.held.is_alive and slave != victim:
				slave.set_hp(-sender.static_stat)
	localize()
	
func on_level_up():
	super.on_level_up()
	harm += 2
	if level >= 3:
		harm_per_static += 1

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
