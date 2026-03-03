extends Item

var owner: SlaveNode

func on_start_battle(sender: SlaveNode):
	super.on_start_battle(sender)
	sender.attacked.connect(_fastest_gun)
	owner = sender

func _fastest_gun(victim: SlaveNode) -> void:
	if victim.held.speed >= owner.held.speed:
		owner.set_speed(+1)

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	ally.add_buff(Action.SHIELD, 1)

func on_level_up():
	super.on_level_up()
	extra_hp += 1
	extra_speed += 1
	

func get_priority(sender: SlaveNode, _ally: SlaveNode) -> int:
	var faster_than = 0
	for boy in Battle.instance.good_team.boys:
		if sender.held.speed > boy.speed:
			faster_than += 1
	return faster_than - Battle.instance.good_team.boys.size() / 2

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	for i in range(Battle.instance.evil_team.boys_nodes.size()):
		intention.targets.append(i)
	return intention
