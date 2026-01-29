extends Item

@export var base_harm: int = 2
@export var extra_harm: int = 2

func localize():
	super.localize()
	desc = desc.format([base_harm, extra_harm], "{}")

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	
	var dmg = base_harm + extra_harm * abs(sender.held.speed - victim.held.speed)
	Action.deal_damage(sender, victim, dmg)

func on_level_up():
	match(level):
		2: extra_harm += 1
		3: base_harm += 2
		4: base_harm += 2
		5: extra_harm += 1
	super.on_level_up()

func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return 0

func get_harm() -> int:
	return base_harm + extra_harm * randi_range(0, 4)

func get_displayed_harm(sender: SlaveNode, victim: SlaveNode) -> int:
	var dmg = base_harm + extra_harm * abs(sender.held.speed - victim.held.speed)
	return Action.calculate_damage(sender, victim, dmg)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.DamageSingular)
	intention.effect = func(v):
		use_item(sender, v)
	return intention
