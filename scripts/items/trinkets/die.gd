extends Item

@export var luck: int = 5

func localize():
	super.localize()
	desc = desc.format([luck], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.set_luck(+luck)
