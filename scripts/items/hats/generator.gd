extends Item

@export var static_gain: int = 0

func localize():
	super.localize()
	desc = desc.format([static_gain], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.tags.append(Action.TAG_PERMANENT_STATIC)

func on_unequip_battle(owner: SlaveNode):
	super.on_unequip_battle(owner)
	owner.tags.erase(Action.TAG_PERMANENT_STATIC)

func on_equip_battle(owner: SlaveNode):
	super.on_equip_battle(owner)
	owner.tags.append(Action.TAG_PERMANENT_STATIC)

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.set_static(+static_gain)

func on_level_up():
	super.on_level_up()
	static_gain += level

func get_priority(sender: SlaveNode, ally: SlaveNode) -> int:
	if not ally.held.is_alive: return -999
	var prio := 0
	if sender == ally:
		prio += 1
	if ally.static_stat < static_gain:
		prio += 1
	if ally.static_stat < 2*static_gain:
		prio += 1
	return prio

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
