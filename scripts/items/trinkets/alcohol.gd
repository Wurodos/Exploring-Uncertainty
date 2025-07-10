extends Item

var sender : SlaveNode

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	owner.turn_started.connect(_on_turn_started)

func _on_turn_started():
	sender.set_power(+1)
	sender.set_hp(-2)		
