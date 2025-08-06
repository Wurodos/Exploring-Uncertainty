extends Enemy

func _init() -> void:
	super._init()

# weapon = +1 heal range
# hat = shield 1st turn
# trinket = 
#	1 = powerup increase
#	2 = +1 speed

var _heal_increase = 0
var _power_up_increase = 0

func update_stats(node: SlaveNode) -> void:
	if hat.is_item(): 
		node.add_buff(Action.SHIELD, 1)
	if weapon.is_item(): _heal_increase += 1
	if trinket1.is_item():
		_power_up_increase += 1
	if trinket2.is_item():
		node.set_speed(+1)

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
			intention = Intention.new(Intention.Type.HealSingle, randi_range(5,10)+_heal_increase)
			intention.target = _get_random_evil_target()
		1:
			intention = Intention.new(Intention.Type.HealMultiple, 2+_heal_increase)
			intention.extra_effect = func() :
				for slave : SlaveNode in Battle.instance.evil_team.boys_nodes:
					if slave.held.is_alive:
						slave.add_buff(Action.SHIELD, 1)
			intention.target = Intention.Target.All
		2:
			intention = Intention.new(Intention.Type.PowerUp, 2 + _power_up_increase)
			intention.target = _get_random_evil_target(false)
