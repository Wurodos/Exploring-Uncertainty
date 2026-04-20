extends Reptile

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

func decide_intention() -> void:
	super.decide_intention()
	
	
		
	
	var weak_slave_id : int = Battle.instance.good_team.boys_nodes.find_custom \
		(func(slave: SlaveNode): return slave.held.hp <= Action.calculate_damage(owner, slave, 10) and slave.held.is_alive)
	var faster_slave_id: int = Battle.instance.good_team.boys_nodes.find_custom \
		(func(slave: SlaveNode): return slave.held.speed > speed and slave.held.is_alive)
	
	
	if owner.team.boys.size() == 1 and times_summoned < 5:
		intention.type = Intention.Type.Reinforcement
		intention.amount = 2
		intention.extra_data = "starry"
		intention.is_support = true
	elif weak_slave_id != -1:
		intention.type = Intention.Type.DamageSingular
		intention.is_support = false
		intention.is_melee = true
		intention.amount = Action.calculate_damage(owner, Battle.instance.good_team.boys_nodes[weak_slave_id], 10)
		intention.effect = func(v: SlaveNode):
			Action.deal_damage(owner, v, 10)
		intention.targets = [weak_slave_id]
	elif faster_slave_id != -1:
		intention.type = Intention.Type.DamageSingular
		intention.is_support = false
		intention.is_melee = true
		intention.amount = Action.calculate_damage(owner, Battle.instance.good_team.boys_nodes[faster_slave_id], 4)
		intention.effect = func(v: SlaveNode):
			Action.deal_damage(owner, v, 4)
			v.set_speed(-2)
		intention.targets = [faster_slave_id]
	else:
		intention.type = Intention.Type.DamageTwo
		intention.is_support = false
		intention.is_melee = true
		intention.amount = Action.calculate_damage(owner, null, 4)
		intention.effect = func(v: SlaveNode):
			Action.deal_damage(owner, v, 4)
		intention.targets = []
		var targets_left := 2
		var i = 0
		for slave in Battle.instance.good_team.boys_nodes:
			if slave.held.is_alive:
				intention.targets.append(i)
				targets_left -= 1
				if targets_left == 0:
					break
			i += 1



#
