extends Item

@export var harm: int = 0
@export var freeze: int = 0
@export var stun: int = 0

var sender: SlaveNode

func localize():
	super.localize()
	desc = desc.format([harm, freeze, stun], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.attacked.connect(_explode)
	sender = owner

func on_unequip_battle(owner: SlaveNode):
	super.on_unequip_battle(owner)
	owner.attacked.disconnect(_explode)

func on_equip_battle(owner: SlaveNode):
	super.on_equip_battle(owner)
	sender = owner
	owner.attacked.connect(_explode)

func _explode(victim: SlaveNode):
	Action.deal_damage(sender, victim, harm)
	victim.add_buff(Action.FREEZE, freeze)
	victim.add_buff(Action.STUN, stun)
	sender.attacked.disconnect(_explode)
	consume(sender)

func on_level_up():
	super.on_level_up()
	harm += roundi(harm / 2)
