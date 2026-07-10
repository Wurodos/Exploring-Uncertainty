extends Item

@export var harm: int = 8

var sender: SlaveNode

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.attacked.connect(_explode)
	sender = owner

func on_unequip_battle(owner: SlaveNode):
	super.on_unequip_battle(owner)
	
	if owner.attacked.is_connected(_explode):
		owner.attacked.disconnect(_explode)

func on_equip_battle(owner: SlaveNode):
	super.on_equip_battle(owner)
	owner.attacked.connect(_explode)

func _explode(victim: SlaveNode):
	if not victim.buffs.has(Action.SHIELD):
		Action.deal_damage(sender, victim, harm)
	sender.attacked.disconnect(_explode)
	consume(sender)

func on_level_up():
	super.on_level_up()
	harm += roundi(harm / 2)
