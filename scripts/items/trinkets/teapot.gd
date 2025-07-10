extends Item

var sender: SlaveNode

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	owner.received_damage.connect(_revenge)
	
func _revenge(source: SlaveNode, _dmg: int):
	Action.deal_damage(sender, source, 2)
