extends Enemy

func _init() -> void:
	super._init()

# weapon = +3 dmg
# hat = shield 1st turn
# trinket = 
# 	1 - +2 hp, +1 dmg
#	2 - +3 hp, +1 dmg

var _dmg_increase = 0

func update_stats(node: SlaveNode) -> void:
	if hat.is_item(): 
		node.add_buff(Action.SHIELD, 1)
	if weapon.is_item(): _dmg_increase += 3
	if trinket1.is_item():
		node.set_hp(2)
		_dmg_increase += 1
	if trinket2.is_item():
		node.set_hp(3)
		_dmg_increase += 1

# attacks one target, frail, but fast

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	intention = Intention.new(Intention.Type.DamageSingular, 5+_dmg_increase)
	intention.target = _get_random_good_target()
