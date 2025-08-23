extends Enemy

@export var power_gain: int = 2
@export var shield_turns: int = 1
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

# either attacks or powers and shields up (does it in groups of 2)


var previous = 0

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	
	var current : int
	
	if previous == 0:
		current = [-1, 1].pick_random()
		previous = current
	else: 
		current = -previous
		previous = current
	
	if current == 1:
		intention = Intention.new(Intention.Type.DamageSingular, randi_range(harm_lower,harm_higher))
		intention.target = _get_random_good_target()
	elif current == -1:
		intention = Intention.new(Intention.Type.PowerUp, power_gain)
		intention.extra_effect = func() :
			node.add_buff(Action.SHIELD, shield_turns)
		intention.target = _get_self_target()
	
	
	
