extends Enemy

@export var harm: int = 2

func _init() -> void:
	super._init()
	
func localize() -> void:
	super.localize()
	info[0] = info[0].format([harm], "{}")

# weapon = +1 dmg
# hat = +1 luck
# trinket = 
# 	1 - +1 speed
#	2 - +1 speed

func update_stats(node: SlaveNode) -> void:
	if hat.is_item(): 
		node.set_luck(+1)
	if weapon.is_item(): harm += 1
	if trinket1.is_item():
		node.set_speed(+1)
	if trinket2.is_item():
		node.set_speed(+1)
	localize()

# attacks everyone (no other move)

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	intention = Intention.new(Intention.Type.DamageMultiple, harm)

	intention.target = Intention.Target.All
