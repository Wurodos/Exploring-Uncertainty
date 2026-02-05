extends Enemy

@export var harm: int = 5

func _init() -> void:
	super._init()

func localize() -> void:
	super.localize()
	info[0] = info[0].format([harm], "{}")

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	owner = node
	localize()

# STRATEGY: HIT AND RUN
# tries to run when hp < 50% or on turn 4

# Ignores hats if their priority is less than +1
# Chooses targets for weapons randomly
func decide_intention() -> void:
	super.decide_intention()
	
	if not owner.held.weapon.is_item():
		intention = Intention.new(Intention.Type.Run)
		return
	
	var hat_target: int = -1
	var max_priority: int = 0
	for i in range(Battle.instance.evil_team.boys_nodes.size()):
		var slave = Battle.instance.evil_team.boys_nodes[i]
		var priority = owner.held.hat.get_priority(owner, slave)
		if owner.held.hat.target == Item.Target.Self and owner != slave: continue
		if priority > max_priority:
			max_priority = priority
			hat_target = i
	decide_weapon_intention()

func decide_weapon_intention() -> void:
	var target = _get_random_good_target()
	var victim = Battle.instance.good_team.boys_nodes[target]
	
	intention = owner.held.weapon.get_intention(owner)
	intention.amount = owner.held.weapon.get_displayed_harm(owner, victim)
	
	if intention.targets.is_empty():
		intention.targets = [target]
