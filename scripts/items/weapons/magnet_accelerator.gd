extends Item

@export var harm: int = 7
@export var stuns: int = 0

var stuns_left: int = 0

func localize():
	super.localize()
	desc = desc.format([harm, stuns], "{}")

func on_start_battle(owner: SlaveNode):
	stuns_left = stuns
	owner.turn_ended.connect(on_end_turn)

func on_end_turn() -> void:
	stuns_left -= 1

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)
	if stuns_left > 0: victim.add_buff(Action.STUN, 1)
	localize()
	
func on_level_up():
	super.on_level_up()
	stuns += 1

func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return +3

func get_harm() -> int:
	return harm

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	return Action.calculate_damage(sender, victim, harm)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageSingular)
	intention.effect = func(v):
		use_item(sender, v)
	return intention
