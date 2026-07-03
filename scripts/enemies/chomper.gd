extends Enemy

@export var harm: int = 2

func _init() -> void:
	super._init()
	
func localize() -> void:
	super.localize()

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	localize()

# Attacks everyone
# Can never wield weapons

func decide_intention() -> void:
	super.decide_intention()
	intention = Intention.new(Intention.Type.DamageMultiple, harm)
	intention.type = Intention.Type.DamageSingular
	intention.amount = Action.calculate_damage(owner, null, harm)
	intention.is_support = false
	intention.effect = func(v: SlaveNode):
		Action.deal_damage(owner, v, harm)
	for i in range(Battle.instance.good_team.boys_nodes.size()):
		intention.targets.append(i)
