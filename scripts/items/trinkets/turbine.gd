extends Item

@export var speed_per_turn: int = 1

var sender : SlaveNode

func localize():
	super.localize()
	desc = desc.format([speed_per_turn], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	owner.turn_ended.connect(_on_turn_ended)

func on_unequip_battle(owner: SlaveNode):
	super.on_unequip_battle(owner)
	owner.turn_ended.disconnect(_on_turn_ended)

func on_equip_battle(owner: SlaveNode):
	super.on_equip_battle(owner)
	sender = owner
	owner.turn_ended.connect(_on_turn_ended)

func _on_turn_ended():
	sender.set_speed(+speed_per_turn)

func on_level_up():
	super.on_level_up()
	if level % 2 == 0:
		extra_speed += 1
	else: speed_per_turn += 1
