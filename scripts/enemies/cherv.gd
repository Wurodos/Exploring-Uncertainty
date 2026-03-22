extends Enemy

class_name Cherv

@export var harm_lower: int = 2
@export var harm_higher: int = 5

var used_hat: bool = false
var dont_change_target: bool = false

func _init() -> void:
	super._init()
	
func localize() -> void:
	super.localize()
	info[0] = info[0].format([harm_lower, harm_higher], "{}")

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	owner = node
	localize()

# attacks randomly
# changes target if attacked, new target is attacker
func on_attacked(attacker: SlaveNode) -> void:
	super.on_attacked(attacker)
	if dont_change_target: return
	if intention:
		if intention.is_support: decide_weapon_intention()
		if intention.targets.size() == 1:
			intention.targets = [Battle.instance.good_team.boys_nodes.find(attacker)]
		owner.update_intention()



# Ignores hats if their priority is less than +1
# Chooses targets for weapons randomly
func decide_intention() -> void:
	super.decide_intention()
	dont_change_target = false
	
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
	var burning_road_dmg = randi_range(harm_lower, harm_higher)
	var target = _get_random_good_target()
	var victim = Battle.instance.good_team.boys_nodes[target]
	
	if owner.held.weapon.is_item() and burning_road_dmg <= owner.held.weapon.get_harm():
		_intention_weapon(target, victim)
	else:
		intention.type = Intention.Type.DamageSingular
		intention.is_support = false
		intention.amount = Action.calculate_damage(owner, victim, burning_road_dmg)
		intention.effect = func(v: SlaveNode):
			Action.deal_damage(owner, v, burning_road_dmg)
		if intention.targets.is_empty():
			intention.targets = [target]
	
