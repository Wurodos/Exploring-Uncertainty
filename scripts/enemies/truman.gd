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
	owner.z_index = 1
	owner.received_damage.connect(_on_received_damage)
	localize()

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
	intention.type = Intention.Type.Support
	intention.is_support = true
	intention.timer = timer_turns
	intention.timer_damage_max = timer_damage
	intention.timer_damage_remain = timer_damage
	intention.effect = func(v: SlaveNode):
		if (v.held as Enemy).intention.timer > 0:
			(v.held as Enemy).intention.timer -= 1
			v.update_intention()
		else:
			v.set_speed(+2)
			v.add_buff(Action.SHIELD, 3)
	intention.targets = []
	for i in range(Battle.instance.evil_team.boys_nodes.size()):
		intention.targets.append(i)
	
