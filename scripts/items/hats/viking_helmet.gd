extends Item

@export var turns: int = 2

func localize():
	super.localize()
	desc = desc.format([turns], "{}")

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	sender.add_buff(Action.APPETITE, turns)
	if ally != sender:
		ally.add_buff(Action.APPETITE, turns)

func on_start_battle(owner: SlaveNode):
	owner.tags.append(Action.TAG_VIGILANCE_KEEP_ATTACK)

func on_level_up():
	extra_hp += 3
	if level >= 3: turns += 1
	if level >= 4: extra_speed += 1
	super.on_level_up()

func get_priority(sender: SlaveNode, ally: SlaveNode) -> int:
	if sender == ally and sender.team.boys.size() > 1: return -2
	
	var prio : int = ally.held.weapon.get_harm() / 9
	if not sender.vigilance: prio += 1
	return prio

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
