extends Item

var sender : SlaveNode
var _timer : int = 0

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	_timer = 0
	owner.turn_ended.connect(_on_turn_ended)

func _on_turn_ended():
	_timer += 1
	if _timer == 5:
		sender.set_power(+5)
		sender.add_buff("shield", 3)
		Action.heal(sender, sender, sender.held.maxhp / 5)		
