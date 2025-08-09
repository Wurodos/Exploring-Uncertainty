extends Item

var sender: SlaveNode

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.attacked.connect(_explode)
	sender = owner

func _explode(victim: SlaveNode):
	Action.deal_damage(sender, victim, 8)
	sender.attacked.disconnect(_explode)
	sender.remove_item(u_name)
