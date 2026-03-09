extends Item

@export var full_harm : int = 10
@export var weak_harm : int = 1

var counter: int = 0
var is_reset_counter: bool = false

func localize():
	super.localize()
	desc = desc.format([full_harm, weak_harm], "{}")



func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	counter = 0
	owner.turn_ended.connect(func(): _on_turn_end())

func _on_turn_end() -> void:
	if is_reset_counter: 
		counter = 1
		is_reset_counter = false
	else: counter -= 1

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	
	if counter > 0:
		Action.deal_damage(sender, victim, weak_harm)
	else:
		Action.deal_damage(sender, victim, full_harm)
	is_reset_counter = true

func on_level_up():
	super.on_level_up()
	full_harm += 2
	if level >= 4: full_harm += 1
	weak_harm += 2

func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return 0

func get_harm() -> int:
	if counter > 0: return weak_harm
	else: return full_harm

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	return Action.calculate_damage(sender, victim, get_harm())

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageSingular)
	intention.effect = func(v):
		use_item(sender, v)
	return intention
