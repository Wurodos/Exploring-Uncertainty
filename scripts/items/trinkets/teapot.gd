extends Item

@export var harm: int = 2

var sender: SlaveNode

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	owner.received_damage.connect(_revenge)
	
func _revenge(source: SlaveNode, _dmg: int):
	Action.deal_damage(sender, source, harm, true)
