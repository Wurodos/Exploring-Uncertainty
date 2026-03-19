extends Item

@export var harm: int = 7

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	
	var lower_level_hat = ItemPool.fetch("no_hat")
	if victim.held.hat.level > 1:
		lower_level_hat = ItemPool.fetch(victim.held.hat.u_name)
		for i in range(victim.held.hat.level-2):
			lower_level_hat.level_up()
	victim.remove_item(victim.held.hat.u_name)
	victim.held.equip(lower_level_hat)
	victim.reapply()
	
	if victim.held is Enemy and victim.get_node("Intention").visible:
		victim._decide_intentions()
	
	Action.deal_damage(sender, victim, harm)
	
	
func on_level_up():
	super.on_level_up()
	harm += level
	localize()

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
