extends Item

@export var full_harm : int = 10
@export var weak_harm : int = 1

var counter: int = 0

func localize():
	super.localize()
	desc = desc.format([full_harm, weak_harm], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	counter = 0
	owner.turn_ended.connect(func(): counter -= 1)

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	
	if counter > 0:
		Action.deal_damage(sender, victim, weak_harm)
	else:
		Action.deal_damage(sender, victim, full_harm)
	
	counter = 2
