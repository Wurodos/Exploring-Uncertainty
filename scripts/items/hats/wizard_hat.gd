extends Item

@export var heal: int = 8

func localize():
	super.localize()
	desc = desc.format([heal], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.heal(sender, victim, heal)

func on_level_up():
	extra_hp += 2
	heal += 2
	super.on_level_up()
