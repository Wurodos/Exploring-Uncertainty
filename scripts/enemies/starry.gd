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
	info[0] = info[0].format([power_gain, shield_turns], "{}")
	info[1] = info[1].format([harm_lower, harm_higher], "{}")

# weapon = +2 dmg range
# hat = shield gain increase
# trinket = 
# 	1 - +2 hp +1 speed
#	2 - +3 hp +1 powerup

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	if hat.is_item(): 
		shield_turns += 1
	if weapon.is_item():
		harm_lower += 4
		harm_higher += 4
	if trinket1.is_item():
		node.set_max_hp(+2) 
		node.set_hp(+2) 
		node.set_speed(+1)
	if trinket2.is_item():
		node.set_max_hp(+3)
		node.set_hp(+3) 
		power_gain += 2
	localize()

# Commands troops 
# If there are cherv(s) in the battle: will order them to attack
# Else if there are chomper(s): will shield 1 turn and power 1 to self
# Else rotates between:
#	1) Attack
#	2) Summon naked cherv if there's space, otherwise shield + power



var times_attacked: int = 0

func on_attacked(attacker: SlaveNode) -> void:
	super.on_attacked(attacker)
	if intention.type == Intention.Type.DamageSingular or intention.type == Intention.Type.OrderChervs:
		intention.target = _convert_node_to_target(attacker)
		owner.update_intention()

func decide_intention() -> void:
	super.decide_intention()
	
	var alive_n = 0
	for ally : SlaveNode in owner.team.boys_nodes:
		if ally.held.is_alive:
			alive_n += 1
	
	for ally : SlaveNode in owner.team.boys_nodes:
		if ally.held.is_alive and ally.held.u_name == "cherv":
			intention = Intention.new(Intention.Type.OrderChervs)
			intention.target = _get_random_good_target()
			return 	
	
	# if no chervs
	
	for ally : SlaveNode in owner.team.boys_nodes:
		if ally.held.is_alive and ally.held.u_name == "chomper":
			intention = Intention.new(Intention.Type.HealSingle, heal_amount)
			intention.target = _get_self_target()
			intention.extra_effect = func() :
				owner.add_buff(Action.SHIELD, 1)
			return 	
	 
	# if no chervs nor chompers
	if alive_n < 3 and hp > maxhp * 4 / 5:
		intention = Intention.new(Intention.Type.SummonCherv, 1)
	elif times_attacked % 2 == 1:
		intention = Intention.new(Intention.Type.PowerUp, power_gain)
		intention.target = _get_self_target()
		intention.extra_effect = func():
			owner.add_buff(Action.SHIELD, shield_turns)
		times_attacked += 1
	else:
		intention = Intention.new(Intention.Type.DamageSingular, randi_range(harm_lower, harm_higher))
		intention.target = _get_random_good_target()
		times_attacked += 1
	
		
	
