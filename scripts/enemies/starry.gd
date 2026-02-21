extends Enemy

@export var power_gain: int = 2
@export var shield_turns: int = 1
@export var heal_amount: int = 5
@export var harm_lower: int = 5
@export var harm_higher: int = 8


func _init() -> void:
	super._init()

func localize() -> void:
	super.localize()

# weapon = +2 dmg range
# hat = shield gain increase
# trinket = 
# 	1 - +2 hp +1 speed
#	2 - +3 hp +1 powerup

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	localize()

# Commands chervs 
# If <2 chervs and didnt do this last turn, summons 1 with random items 
#		(max x3 per battle)
# 1.	There is someone chervs can kill with collective damage:
#		Every cherv receives +1 power, focuses specific target (no narrowmind)
# 		Only if no other starrys do this
# 2.	Uses hat on self/not cherv if priority is at least +2
# 3.	Uses hat on cherv that is attacking. They attack instantly 
# 4. 	Uses weapon

var times_attacked: int = 0

func on_attacked(attacker: SlaveNode) -> void:
	super.on_attacked(attacker)

var reinforced_last_turn := false
var summons_left := 3

func decide_intention() -> void:
	super.decide_intention()
	
	var cherv_count := Battle.instance.evil_team.boys.filter(func(boy: Slave): return boy.u_name == "cherv").size()
	if summons_left > 0 and cherv_count < 2 and not reinforced_last_turn:
		summons_left -= 1
		intention.type = Intention.Type.Reinforcement
		intention.is_support = true
		reinforced_last_turn = true
		return
	
	reinforced_last_turn = false
	var hat_target: int = -1
	var max_priority: int = -1
	var extra_action := false
	var starry_order := false
	var chervs: Array[Cherv] = []
	
	for i in range(Battle.instance.evil_team.boys_nodes.size()):
		var slave = Battle.instance.evil_team.boys_nodes[i]
		var priority = owner.held.hat.get_priority(owner, slave)
		
		if (slave.held as Enemy).intention.type == Intention.Type.OrderChervs:
			starry_order = true
		if slave.held is Cherv: chervs.append(slave.held)
		
		if owner.held.hat.target == Item.Target.Self and owner != slave: continue
		if priority < +2 and (not slave.held is Cherv or (slave.held as Enemy).intention.is_support):
			continue
		if priority > max_priority:
			max_priority = priority
			extra_action = slave.held.u_name == "cherv"
			hat_target = i
	if not starry_order:
		var order_victim := -1
		
		for i in range(Battle.instance.good_team.boys_nodes.size()):
			var victim = Battle.instance.good_team.boys_nodes[i]
			if not victim.held.is_alive: continue
			var cherv_total_damage := 0
			for cherv in chervs:
				cherv_total_damage += 1 + cherv.weapon.get_displayed_harm(cherv.owner, victim)
			if victim.held.hp <= cherv_total_damage:
				order_victim = i
		
		if order_victim != -1:
			intention.type = Intention.Type.OrderChervs
			intention.is_support = true
			intention.targets = [order_victim]
			return	
	
	if hat_target > -1:
		intention = owner.held.hat.get_intention(owner)
		
		if extra_action:
			var fun := intention.effect
			var cherv = Battle.instance.evil_team.boys_nodes[hat_target]
			intention.effect = func(v):
				fun.call(v)
				var victim : SlaveNode = Battle.instance.good_team.boys_nodes.filter(func(enemy: SlaveNode): return enemy.held.is_alive).pick_random()
				cherv.held.weapon.get_intention(cherv).effect.call(victim)
				cherv.attacked.emit(victim)
				cherv.turn_ended.emit()
						
		if intention.targets.is_empty():
			intention.targets = [hat_target]
	else:
		if weapon.is_item():
			var target = _get_random_good_target()
			var victim = Battle.instance.good_team.boys_nodes[target]	
			_intention_weapon(target, victim)
		else:
			intention.type = Intention.Type.Reinforcement
			intention.is_support = true
	
