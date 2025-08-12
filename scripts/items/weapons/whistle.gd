extends Item

@export var harm: int = 3

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)
