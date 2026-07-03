extends Enemy

@export var harm: int = 5
var turn := 0

func _init() -> void:
	super._init()
	

func _speedup() -> void:
	if not is_instance_valid(owner):
		SignalBus.new_round.disconnect(_speedup)
		return
	
	turn += 1
	if turn == 1:
		return
	
	owner.set_speed(+1)
	

func localize() -> void:
	super.localize()

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	owner = node
	SignalBus.new_round.connect(_speedup)
	localize()

# STRATEGY: HIT AND RUN
# tries to run when hp < 50% or on turn 4

# Ignores hats if their priority is less than +1
# Chooses targets for weapons randomly
func decide_intention() -> void:
	super.decide_intention()
	
	if turn >= 4 or not owner.held.weapon.is_item() or owner.held.hp <= owner.held.maxhp / 2:
		_intention_run()
		return
	
	var target = _get_random_good_target()
	var victim = Battle.instance.good_team.boys_nodes[target]	
	_intention_weapon(target, victim)
