extends Item

@export var initiative_gain: int = 1
@export var heal: int = 2

func localize():
	super.localize()
	desc = desc.format([initiative_gain, heal], "{}")

func use_item(sender: SlaveNode, ally: SlaveNode):
	ally.set_speed(+initiative_gain)
	Action.heal(sender, ally, +heal)
