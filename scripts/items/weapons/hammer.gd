extends Item

@export var harm: int = 6

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	victim.remove_buff(Action.SHIELD)
	Action.deal_damage(sender, victim, harm)
