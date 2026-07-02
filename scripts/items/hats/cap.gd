extends Item

@export var exp_gain: int = 0

func localize():
	super.localize()
	desc = desc.format([exp_gain], "{}")

func on_end_battle(owner: Slave):
	super.on_end_battle(owner)
	if CurrentRun.is_in_purged: return
	
	for item in owner.get_all_items():
		if item != self:
			for i in range(exp_gain):
				item.gain_exp(owner)

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	if not ally.held.is_alive: return
	
	_swap(sender, ally)	
	# Swap back if hp <= 0
	if sender.held.hp <= 0 or ally.held.hp <= 0:
		_swap(sender, ally)

func _swap(sender: SlaveNode, ally: SlaveNode):
	var ally_hat: Item = ally.held.hat
	
	ally.remove_item(ally_hat.u_name)
	ally.held.equip(self)
	ally.reapply()
	
	sender.remove_item(u_name)
	sender.held.equip(ally_hat)
	sender.reapply()
	

func on_level_up():
	super.on_level_up()
	if level == 3 or level == 5: exp_gain += 1
	else:
		extra_hp += 2 
		extra_speed += 1
