extends Item

@export var base_harm: int = 2
@export var extra_harm: int = 2

func localize():
	super.localize()
	desc = desc.format([base_harm, extra_harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	
	var dmg = base_harm + max(0, extra_harm * (sender.held.speed - victim.held.speed))
	Action.deal_damage(sender, victim, dmg)
