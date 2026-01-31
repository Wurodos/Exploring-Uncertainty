extends Item

@export var turns: int = 3

func localize():
	super.localize()
	desc = desc.format([turns], "{}")

func on_start_battle(owner: SlaveNode):
	if not owner.tags.has(Action.TAG_BETTER_SHIELD):
		owner.tags.append(Action.TAG_BETTER_SHIELD)

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	sender.add_buff(Action.SHIELD, turns)

func on_level_up():
	extra_hp += 3
	if level == 3: extra_speed += 1
	if level >= 4: turns += 1
	super.on_level_up()

func get_priority(sender: SlaveNode, _ally: SlaveNode) -> int:
	if not sender.buffs.has(Action.SHIELD): 
		return +1
	else: 
		return 0

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.PowerUp, sender.power / 2 + sender.power % 2)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
