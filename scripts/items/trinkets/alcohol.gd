extends Item

var sender : SlaveNode

@export var power_gain: int = 1
@export var health_loss: int = 2

func localize():
	super.localize()
	desc = desc.format([power_gain, health_loss], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	owner.turn_started.connect(_on_turn_started)

func _on_turn_started():
	sender.set_power(+power_gain)
	sender.set_hp(-health_loss)		

func on_level_up():
	match(level):
		2: health_loss += 1
		3: 
			power_gain += 1 
			health_loss += 1
		4: health_loss -= 1
		5: health_loss -= 1
	super.on_level_up()
