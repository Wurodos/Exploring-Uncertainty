extends Item

@export var turns: int = 4
@export var power_gain: int  = 5
@export var shield_turns: int = 3
@export var heal_hp_percent: int = 20

var sender : SlaveNode
var _timer : int = 0

func localize():
	super.localize()
	desc = desc.format([turns, power_gain, shield_turns, heal_hp_percent], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	_timer = 0
	owner.turn_ended.connect(_on_turn_ended)

func _on_turn_ended():
	_timer += 1
	if _timer == turns:
		sender.set_power(+power_gain)
		sender.add_buff("shield", shield_turns)
		Action.heal(sender, sender, sender.held.maxhp / (100.0 / heal_hp_percent))		
