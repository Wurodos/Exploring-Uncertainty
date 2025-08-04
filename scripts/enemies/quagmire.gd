extends Enemy

func _init() -> void:
	super._init()

# weapon = +2 dmg range
# hat = +3 hp
# trinket = +2 hp
# 	1 - +1 dmg range
#	2 - +1 speed

var _dmg_increase = 0

func update_stats(node: SlaveNode) -> void:
	if hat.is_item(): 
		node.set_max_hp(3)
		node.set_hp(3)
	if weapon.is_item(): _dmg_increase += 2
	if trinket1.is_item():
		node.set_max_hp(2) 
		node.set_hp(2)
		_dmg_increase += 1
	if trinket2.is_item():
		node.set_max_hp(2)
		node.set_hp(2) 
		node.set_speed(1)

# attacks randomly

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
			intention = Intention.new(Intention.Type.HealSingle, randi_range(5,10))
			intention.target = _get_random_evil_target()
		1:
			intention = Intention.new(Intention.Type.HealMultiple, 2)
			intention.extra_effect = func() :
				for slave : SlaveNode in Battle.instance.evil_team.boys_nodes:
					if slave.held.is_alive:
						slave.add_buff(Action.SHIELD, 1)
			intention.target = Intention.Target.All
		2:
			intention = Intention.new(Intention.Type.PowerUp, 2)
			intention.target = _get_random_evil_target(false)
