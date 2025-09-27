extends Reptile

func _init() -> void:
	super._init()
	is_final_boss = true


# Start of battle: enemies receive DARK 37 turns
# First move: FREEZE to all 5 turns, 3 harm
# In random order once: 
#	(a) Summon Tractor, 
#	(b)

var times_summoned : int = 0
var _extra_damage: int = 0

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	



#
