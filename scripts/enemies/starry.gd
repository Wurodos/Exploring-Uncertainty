extends Enemy

func _init() -> void:
	super._init()

# weapon = +2 dmg range
# hat = +3 hp
# trinket = +2 hp
# 	1 - +1 dmg range
#	2 - +1 speed

var _dmg_increase = 0

func update_stats(node: SlaveNode) -> void:
	if hat.is_item(): 
		node.set_max_hp(3)
		node.set_hp(3)
	if weapon.is_item(): _dmg_increase += 2
	if trinket1.is_item():
		node.set_max_hp(2) 
		node.set_hp(2)
		_dmg_increase += 1
	if trinket2.is_item():
		node.set_max_hp(2)
		node.set_hp(2) 
		node.set_speed(1)

# attacks randomly

var previous = 0

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	
	var current : int
	
	if previous == 0:
		current = [-1, 1].pick_random()
		previous = current
	else: 
		current = -previous
		previous = 0
	
	if current == 1:
		intention = Intention.new(Intention.Type.DamageSingular, randi_range(5, 8)+_dmg_increase)
		intention.target = _get_random_good_target()
	elif current == -1:
		intention = Intention.new(Intention.Type.PowerUp, 1)
		intention.extra_effect = func() :
			node.add_buff(Action.SHIELD, 2)
		intention.target = _get_self_target()
	
	
	
