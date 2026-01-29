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
	super.update_stats(node)
	if hat.is_item():
		harm += 1
	if weapon.is_item(): harm += 2
	if trinket1.is_item():
		harm += 1
		node.set_speed(+1)
	if trinket2.is_item():
		harm += 1
		node.set_speed(+1)
	localize()

# attacks everyone (no other move)

func decide_intention() -> void:
	super.decide_intention()
	intention = Intention.new(Intention.Type.DamageMultiple, harm)
