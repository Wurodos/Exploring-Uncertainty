extends Item

@export var turns: int = 3

func localize():
	super.localize()
	desc = desc.format([turns], "{}")

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	sender.add_buff(Action.SHIELD, turns)

func on_level_up():
	extra_hp += 3
	if level == 3: extra_speed += 1
	if level >= 4: turns += 1
	super.on_level_up()
