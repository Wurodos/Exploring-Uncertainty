extends Enemy

@export var harm_lower: int = 2
@export var harm_higher: int = 5


func _init() -> void:
	super._init()
	
func localize() -> void:
	super.localize()
	info[0] = info[0].format([harm_lower, harm_higher], "{}")

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
	if weapon.is_item():
		harm_lower += 2
		harm_higher += 2
	if trinket1.is_item():
		node.set_max_hp(2) 
		node.set_hp(2)
		harm_lower += 1
		harm_higher += 1
	if trinket2.is_item():
		node.set_max_hp(2)
		node.set_hp(2) 
		node.set_speed(1)
	localize()

# attacks randomly

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	intention = Intention.new(Intention.Type.DamageSingular, randi_range(harm_lower, harm_higher))
	
	intention.target = _get_random_good_target()
