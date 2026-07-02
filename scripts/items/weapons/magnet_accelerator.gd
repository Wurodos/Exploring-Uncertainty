extends Item

@export var harm: int = 7
@export var stuns: int = 0

var stuns_left: int = 0
var attacked_this_turn: bool = false

func localize():
	super.localize()
	desc = desc.format([harm, stuns], "{}")

func on_start_battle(owner: SlaveNode):
	stuns_left = stuns
	owner.turn_ended.connect(on_end_turn)

func on_end_turn() -> void:
	if attacked_this_turn:
		stuns_left -= 1
		attacked_this_turn = false

func on_unequip_battle(owner: SlaveNode):
	super.on_unequip_battle(owner)
	owner.turn_ended.disconnect(on_end_turn)

func on_equip_battle(owner: SlaveNode):
	super.on_equip_battle(owner)
	owner.turn_ended.connect(on_end_turn)

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)
	attacked_this_turn = true
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
