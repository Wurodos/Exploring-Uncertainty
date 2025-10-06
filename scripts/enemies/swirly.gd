extends Enemy

@export var harm: int = 5

func _init() -> void:
	super._init()

func localize() -> void:
	super.localize()
	info[0] = info[0].format([harm], "{}")

#
#
#
#

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	if hat.is_item(): 
		node.add_buff(Action.SHIELD, 1)
	if weapon.is_item(): harm += 3
	if trinket1.is_item():
		harm += 2
	if trinket2.is_item():
		harm += 2
	localize()

# fast and deals big damage
# but it decreases with each hit
# tries to run when hp < 50%

func decide_intention() -> void:
	super.decide_intention()
	intention = Intention.new(Intention.Type.DamageSingular, harm)
	intention.target = _get_random_good_target()
