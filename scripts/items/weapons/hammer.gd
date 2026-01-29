extends Item

@export var harm: int = 6

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	victim.remove_buff(Action.SHIELD)
	Action.deal_damage(sender, victim, harm)

func on_level_up():
	harm += 1
	super.on_level_up()

# +2 if target has shield
func get_priority(_sender: SlaveNode, victim: SlaveNode) -> int:
	var p = 0
	if victim.buffs.has(Action.SHIELD): p = 2
	return p

func get_harm() -> int:
	return harm

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	var dmg = harm
	if victim.buffs.has(Action.SHIELD): dmg *= 10 / 7
	return Action.calculate_damage(sender, victim, dmg)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageSingular)
	intention.effect = func(v):
		use_item(sender, v)
	return intention
