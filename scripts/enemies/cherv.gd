extends Enemy

class_name Cherv

@export var harm_lower: int = 2
@export var harm_higher: int = 5


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
	if intention:
		intention.targets = [CurrentRun.good_boys.find(attacker.held)]
		owner.update_intention()

func decide_intention() -> void:
	super.decide_intention()
	var burning_road_dmg = randi_range(harm_lower, harm_higher)
	
	var target = _get_random_good_target()
	var victim = Battle.instance.good_team.boys_nodes[target]
	
	if burning_road_dmg <= owner.held.weapon.get_harm():
		intention = owner.held.weapon.get_intention(owner)
		intention.amount = owner.held.weapon.get_displayed_harm(owner, victim)
	else:
		intention.type = Intention.Type.DamageSingular
		intention.amount = Action.calculate_damage(owner, victim, burning_road_dmg)
		intention.effect = func(v: SlaveNode):
			Action.deal_damage(owner, v, burning_road_dmg)
	
	intention.targets = [target]
