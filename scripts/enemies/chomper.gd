extends Enemy

func _init() -> void:
	super._init()

# weapon = +1 dmg
# hat = +1 luck
# trinket = 
# 	1 - +1 speed
#	2 - +1 speed

var _dmg_increase = 0

func update_stats(node: SlaveNode) -> void:
	if hat.is_item(): 
		node.set_luck(+1)
	if weapon.is_item(): _dmg_increase += 1
	if trinket1.is_item():
		node.set_speed(+1)
	if trinket2.is_item():
		node.set_speed(+1)

# attacks everyone (no other move)

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	intention = Intention.new(Intention.Type.DamageMultiple, 2+_dmg_increase)

	intention.target = Intention.Target.All
