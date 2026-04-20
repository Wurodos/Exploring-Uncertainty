extends Enemy

@export var harm: int = 10
@export var timer_turns: int = 3
@export var unstable_turns: int = 3

func _init() -> void:
	super._init()
	
func localize() -> void:
	super.localize()

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	owner = node
	localize()


func decide_intention() -> void:
	super.decide_intention()
	intention.type = Intention.Type.DamageMultiple
	intention.is_support = false
	intention.is_melee = true
	intention.timer = timer_turns
	intention.amount = Action.calculate_damage(owner, null, harm)
	intention.effect = func(v: SlaveNode):
		Action.deal_damage(owner, v, harm)
	intention.targets = []
	for i in range(Battle.instance.good_team.boys_nodes.size()):
		intention.targets.append(i)
	
