extends Item

@export var harm: int = 4
@export var power: int = 1

func localize():
	super.localize()
	desc = desc.format([harm, power], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)
	sender.set_power(+1)

func on_level_up():
	harm += 2
	if level >= 3: power += 1
	super.on_level_up()
