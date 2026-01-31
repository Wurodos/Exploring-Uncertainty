extends Item

@export var speed_loss: int = 1

func localize():
	super.localize()
	desc = desc.format([speed_loss], "{}")

func use_item(_sender: SlaveNode, ally: SlaveNode):
	ally.set_speed(-speed_loss)

func on_level_up():
	extra_hp += 5
	extra_speed -= 1
	super.on_level_up()

func get_priority(_sender: SlaveNode, _ally: SlaveNode) -> int:
	return -999

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.HealSingle)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
