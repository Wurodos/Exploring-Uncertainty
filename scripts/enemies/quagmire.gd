extends Enemy

@export var heal_lower: int = 5
@export var heal_higher: int = 10
@export var heal_team: int = 2
@export var shield_team_turns: int = 1
@export var power_grant: int = 2


func _init() -> void:
	super._init()

func localize() -> void:
	super.localize()
	info[0] = info[0].format([heal_lower, heal_higher], "{}")
	info[1] = info[1].format([heal_team, shield_team_turns], "{}")
	info[2] = info[2].format([power_grant], "{}")

# weapon = +1 heal range
# hat = shield 1st turn
# trinket = 
#	1 = powerup increase
#	2 = +1 speed

func update_stats(node: SlaveNode) -> void:
	if hat.is_item(): 
		node.add_buff(Action.SHIELD, 1)
	if weapon.is_item(): 
		heal_lower += 2
		heal_higher += 2
		heal_team += 2
	if trinket1.is_item():
		power_grant += 1
	if trinket2.is_item():
		node.set_speed(+1)
	localize()

# support, if only quagmires = runs

func decide_intention(node: SlaveNode) -> void:
	super.decide_intention(node)
	
	var alive = 0
	var quags = 0
	for slave in node.team.boys:
		if slave.is_alive: alive += 1
		if slave.u_name == u_name: quags += 1
	if alive == quags:
		intention = Intention.new(Intention.Type.Run, 1)
		return
	
	var r = randi_range(0, 2)
	match(r):
		0:
			intention = Intention.new(Intention.Type.HealSingle, randi_range(heal_lower,heal_higher))
			intention.target = _get_random_evil_target()
		1:
			intention = Intention.new(Intention.Type.HealMultiple, heal_team)
			intention.extra_effect = func() :
				for slave : SlaveNode in Battle.instance.evil_team.boys_nodes:
					if slave.held.is_alive:
						slave.add_buff(Action.SHIELD, shield_team_turns)
			intention.target = Intention.Target.All
		2:
			intention = Intention.new(Intention.Type.PowerUp, power_grant)
			intention.target = _get_random_evil_target(false)
