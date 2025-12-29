extends Item

@export var harm: int = 4
@export var shield_turns: int = 1

func localize():
	super.localize()
	desc = desc.format([harm, shield_turns], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.deal_damage(sender, victim, harm)
	sender.add_buff(Action.SHIELD, shield_turns)

func on_level_up():
	harm += 2
	if level == 3 or level == 5: shield_turns += 1
	super.on_level_up()
