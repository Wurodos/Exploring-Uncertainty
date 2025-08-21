extends Item

var sender: SlaveNode

func localize():
	super.localize()

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.attacked.connect(_hit_everyone)
	owner.turn_ended.connect(func(): sender.remove_buff("shells_used"))
	sender = owner

func _hit_everyone(victim: SlaveNode):
	if sender.buffs.has("shells_used"): return
	
	sender.add_buff("shells_used", 1)
	var weapon: Item = sender.held.weapon
	
	if weapon.target == Item.Target.Single:
		for enemy in victim.team.boys_nodes:
			if enemy != victim:
				weapon.use_item(sender, enemy)
	
	sender.attacked.disconnect(_hit_everyone)
