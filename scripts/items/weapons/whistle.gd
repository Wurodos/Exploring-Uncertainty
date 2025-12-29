extends Item

@export var harm: int = 3

func localize():
	super.localize()
	desc = desc.format([harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)

func on_level_up():
	harm += 1
	if level >= 4: harm += 1
	super.on_level_up()
