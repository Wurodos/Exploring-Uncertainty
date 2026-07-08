extends Enemy

# 


var used_hat: bool = false

func _init() -> void:
	super._init()
	
func localize() -> void:
	super.localize()

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	owner = node
	localize()

# Ignores hats if their priority is less than +1
# Chooses targets for weapons randomly
func decide_intention() -> void:
	super.decide_intention()
	
	var hat_target: int = -1
	var max_priority: int = 0
	for i in range(Battle.instance.evil_team.boys_nodes.size()):
		var slave = Battle.instance.evil_team.boys_nodes[i]
		var priority = owner.held.hat.get_priority(owner, slave)
		if owner.held.hat.target == Item.Target.Self and owner != slave: continue
		if priority > max_priority:
			max_priority = priority
			hat_target = i
	
	if hat_target > -1 and not used_hat:
		used_hat = true
		intention = owner.held.hat.get_intention(owner)
		if intention.targets.is_empty():
			intention.targets = [hat_target]
	else:
		decide_weapon_intention()

func decide_weapon_intention() -> void:
	used_hat = false
	var target = _get_target(func(slave: SlaveNode):
		if not slave.held.is_alive:
			return -INF 
		return -slave.held.hp
	)
	var victim = Battle.instance.good_team.boys_nodes[target]
	_intention_weapon(target, victim)
	
