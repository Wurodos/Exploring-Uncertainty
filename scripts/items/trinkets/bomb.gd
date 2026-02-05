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

func _explode(victim: SlaveNode):
	Action.deal_damage(sender, victim, harm)
	sender.attacked.disconnect(_explode)
	consume(sender)

func on_level_up():
	harm += roundi(harm / 2)
	super.on_level_up()
