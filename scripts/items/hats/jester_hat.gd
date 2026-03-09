extends Item

@export var turns: int = 3

func localize():
	super.localize()
	desc = desc.format([turns], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.tags.append(Action.TAG_STATUS_DAMAGE)

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.add_buff(Action.BLASPHEMY, turns)

func on_level_up():
	super.on_level_up()
	extra_hp += 2
	if level == 3: extra_speed += 1
	if level >= 4: turns += 1

func get_priority(_sender: SlaveNode, ally: SlaveNode) -> int:
	if not ally.held.is_alive: return -999
	
	var prio = 0
	if ally.buffs.has(Action.BLASPHEMY): 
		prio -= 1
		if not ally.tags.has(Action.TAG_STATUS_DAMAGE): prio -= 1
	if ally.tags.has(Action.TAG_STATUS_DAMAGE): prio += 1
	if ally.held.weapon.get_harm() >= 5: prio += 1
	return prio

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
