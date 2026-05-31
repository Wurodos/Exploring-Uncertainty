extends Item

@export var turns: int = 1

func localize():
	super.localize()
	desc = desc.format([turns], "{}")

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.add_buff(Action.PATRIOTISM, turns)

func on_sold(room: Room) -> void:
	if room.type == Room.Type.City:
		room.heal_used = 0

func on_level_up():
	super.on_level_up()
	if level >= 3:
		turns += 1
	else:
		extra_hp += 3

func get_priority(_sender: SlaveNode, ally: SlaveNode) -> int:
	if not ally.buffs.has(Action.PATRIOTISM): 
		return +1
	else: 
		return 0

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support, sender.power / 2 + sender.power % 2)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
