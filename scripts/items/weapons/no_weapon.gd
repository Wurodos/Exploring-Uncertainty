extends Item

@export var harm: int = 2

func localize() -> void:
	super.localize()
	desc = desc.format([harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)

func get_harm() -> int:
	return harm

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	return Action.calculate_damage(sender, victim, harm)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageSingular)
	intention.effect = func(v):
		use_item(sender, v)
	return intention
