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



#
