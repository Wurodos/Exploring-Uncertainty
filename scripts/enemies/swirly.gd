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
	if hat.is_item(): 
		node.add_buff(Action.SHIELD, 1)
	if weapon.is_item(): harm += 3
	if trinket1.is_item():
		harm += 1
	if trinket2.is_item():
		harm += 1
	localize()

# attacks one target, frail, but fast

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	intention = Intention.new(Intention.Type.DamageSingular, harm)
	intention.target = _get_random_good_target()
