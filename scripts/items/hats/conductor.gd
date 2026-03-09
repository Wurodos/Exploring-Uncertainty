extends Item

@export var static_per_power: int = 0

func localize():
	super.localize()
	desc = desc.format([static_per_power], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.tags.append(Action.TAG_STATIC_HEALTH)

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.set_power(sender.static_stat / static_per_power)

func on_level_up():
	super.on_level_up()
	if level >= 3:
		static_per_power -= 1
	else:
		extra_hp += 4


func get_priority(sender: SlaveNode, ally: SlaveNode) -> int:
	if not ally.held.is_alive: return -999
	var prio := sender.static_stat / (static_per_power * 2)
	if sender == ally: prio += 1
	if sender.static_stat < 2 * static_per_power: prio -= 3
	return prio

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
