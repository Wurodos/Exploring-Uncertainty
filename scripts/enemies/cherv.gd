extends Enemy

class_name Cherv

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

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	owner = node
	localize()

# attacks randomly
# changes target if attacked, new target is attacker



func on_attacked(attacker: SlaveNode) -> void:
	super.on_attacked(attacker)
	if intention:
		intention.target = _convert_node_to_target(attacker, CurrentRun.good_boys)
		owner.update_intention()

func decide_intention() -> void:
	super.decide_intention()
	
	intention = Intention.new(Intention.Type.DamageSingular, randi_range(harm_lower, harm_higher))
	
	intention.target = _get_random_good_target()
