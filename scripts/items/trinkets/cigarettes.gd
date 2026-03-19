extends Item

var sender : SlaveNode
@export var health_loss: int = 2
@export var exp_gain: int = 2

func localize():
	super.localize()
	desc = desc.format([health_loss, exp_gain], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	owner.turn_started.connect(_on_turn_started)

func on_end_battle(owner: Slave):
	for i in range(exp_gain):
		owner.weapon.gain_exp(owner)

func _on_turn_started():
	sender.set_hp(-health_loss)		

func on_level_up():
	super.on_level_up()
	if level >= 3: exp_gain += 1
	health_loss += 1
