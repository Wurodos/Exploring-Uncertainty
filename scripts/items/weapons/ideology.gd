extends Item

@export var harm: int = 7

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	if victim.held is Cherv:
		Action.execute(sender, victim)
		return
	elif victim.held is Starry:
		Action.damage_multiplier = 2
	Action.deal_damage(sender, victim, harm)
	Action.damage_multiplier = 1
	
func on_level_up():
	super.on_level_up()
	harm += level
