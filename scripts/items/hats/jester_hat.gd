extends Item

@export var turns: int = 3

func localize():
	super.localize()
	desc = desc.format([turns], "{}")

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.add_buff(Action.BLASPHEMY, turns)
