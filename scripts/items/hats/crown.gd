extends Item

@export var speed_loss: int = 1

func localize():
	super.localize()
	desc = desc.format([speed_loss], "{}")

func use_item(sender: SlaveNode, ally: SlaveNode):
	ally.set_speed(-speed_loss)

func on_level_up():
	extra_hp += 5
	extra_speed -= 1
	super.on_level_up()
