extends Enemy

@export var timer_turns: int = 3
@export var timer_damage: int = 10
@export var timer_increase: int = 10

func _init() -> void:
	super._init()
	
func localize() -> void:
	super.localize()

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	owner = node
	owner.received_damage.connect(_on_received_damage)
	localize()

func on_death() -> void:
	super.on_death()
	for dude in Battle.instance.good_team.boys_nodes:
		dude.remove_buff(Action.DARK)

func _on_received_damage(source: SlaveNode, dmg: int) -> void:
	if intention.timer > 0:
		intention.timer_damage_remain -= dmg
		if intention.timer_damage_remain <= 0:
			intention.timer += 1
			intention.timer_damage_max += timer_increase
			intention.timer_damage_remain = intention.timer_damage_max
		owner.update_intention()

func decide_intention() -> void:
	super.decide_intention()
	intention.type = Intention.Type.Execution
	intention.is_support = false
	intention.is_melee = true
	intention.timer = timer_turns
	intention.timer_damage_max = timer_damage
	intention.timer_damage_remain = timer_damage
	intention.amount = Action.calculate_damage(owner, null, -1)
	intention.effect = func(v: SlaveNode):
		Action.execute(owner, v)
	intention.targets = [_get_target(func(s: SlaveNode): return s.held.hp)]
	
