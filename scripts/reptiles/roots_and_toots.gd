extends Enemy

func _init() -> void:
	super._init()
	is_final_boss = true


# If no alive starries: summons new ones (max 5 times)
# If someone is 10 HP or lower, tries to smash them with 10 dmg
# If at least 2 are faster, attacks fastest with EnSnare (5 dmg, -2 speed)
# Otherwise, attacks 2 random slaves with 4 dmg (can attack same slave twice)


# When <= 30 hp, only does 4 dmg to everyone, kills every starry (+1 power +1 speed each)
# IF GOOD SLAVE DIES, HEALS 15 HP, +1 SPEED, +2 POWER

var times_summoned : int = 0

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	
	var weak_slave_id : int = CurrentRun.good_boys.find_custom \
		(func(slave: Slave): return slave.hp <= 10 and slave.is_alive)
	var faster_slave_id: int = CurrentRun.good_boys.find_custom \
		(func(slave: Slave): return slave.speed > node.held.speed and slave.is_alive)
	
	
	if node.team.boys.size() == 1 and times_summoned < 5:
		intention = Intention.new(Intention.Type.SummonStars, 2)
		times_summoned += 1
	elif weak_slave_id != -1:
		intention = Intention.new(Intention.Type.DamageSingular, 10)
		intention.target = weak_slave_id
	elif faster_slave_id != -1:
		intention = Intention.new(Intention.Type.DamageSingular, 5)
		intention.target = faster_slave_id
		intention.extra_effect = func(): 
			Battle.instance.good_team.boys_nodes[faster_slave_id].set_speed(-2)
	else:
		intention = Intention.new(Intention.Type.DamageTwo, 4)
		intention.target = _get_random_good_target()
		intention.target_second = _get_random_good_target()
		



#
