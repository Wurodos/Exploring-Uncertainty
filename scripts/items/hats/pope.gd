extends Item

@export var absorb_per_slave: int = 1
@export var percentage_restored: int = 10

var sender: SlaveNode

func localize():
	super.localize()
	desc = desc.format([absorb_per_slave, percentage_restored], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	sender = owner
	owner.turn_started.connect(_on_turn_started)

func _on_turn_started():
	for slave in Battle.instance.good_team.boys_nodes:
		if slave.held.is_alive and slave != sender:
			slave.set_hp(-absorb_per_slave)
			sender.set_hp(+absorb_per_slave)
	
	for slave in Battle.instance.evil_team.boys_nodes:
		if slave.held.is_alive and slave != sender:
			slave.set_hp(-absorb_per_slave)
			sender.set_hp(+absorb_per_slave)

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	if not ally.held.is_alive and ally.visible:
		ally.held.is_alive = true
		ally.set_hp(ceil(ally.held.maxhp * percentage_restored / 100.0), false)
		ally.death(true)

func on_level_up():
	super.on_level_up()
	percentage_restored += 10


func get_priority(sender: SlaveNode, ally: SlaveNode) -> int:
	if ally.held.is_alive or not ally.visible: return -999
	if sender.held.hp > sender.held.maxhp / 2:
		return +3
	return +1

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
