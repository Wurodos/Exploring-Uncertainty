extends Reptile

func _init() -> void:
	super._init()
	is_final_boss = true

func on_start_battle(node: SlaveNode) -> void:
	super.on_start_battle(node)
	for slave in Battle.instance.good_team.boys_nodes:
		slave.add_buff(Action.DARK, 3)

func decide_intention() -> void:
	super.decide_intention()
	var target = _get_random_good_target()
	var victim = Battle.instance.good_team.boys_nodes[target]
	_intention_weapon(target, victim)


#
