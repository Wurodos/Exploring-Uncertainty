extends Item

@export var full_harm : int = 10
@export var weak_harm : int = 1

func localize():
	super.localize()
	desc = desc.format([full_harm, weak_harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	if sender.buffs.has("pipe_used"):
		Action.deal_damage(sender, victim, weak_harm)
	else:
		Action.deal_damage(sender, victim, full_harm)
	sender.buffs.set("pipe_used", 2)
	
