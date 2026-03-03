extends Item

@export var harm: int = 4
@export var power: int = 1

func localize():
	super.localize()
	desc = desc.format([harm, power], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)
	sender.set_power(+1)

func on_level_up():
	super.on_level_up()
	harm += 2
	if level >= 3: power += 1

func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return 0

func get_harm() -> int:
	return harm

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	return Action.calculate_damage(sender, victim, harm)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageSingular, get_harm())
	intention.effect = func(v):
		use_item(sender, v)
	return intention
