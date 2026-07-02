extends Item

var sender: SlaveNode
var used: bool = false

func localize():
	super.localize()

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	used = false
	owner.attacked.connect(_hit_everyone)
	owner.turn_ended.connect(func(): sender.remove_buff("shells_used"))
	sender = owner

func on_unequip_battle(owner: SlaveNode):
	super.on_unequip_battle(owner)
	
	if owner.attacked.is_connected(_hit_everyone):
		owner.attacked.disconnect(_hit_everyone)

func on_equip_battle(owner: SlaveNode):
	super.on_equip_battle(owner)
	sender = owner
	owner.attacked.connect(_hit_everyone)
	owner.turn_ended.connect(func(): sender.remove_buff("shells_used"))

func _hit_everyone(victim: SlaveNode):
	if used or sender.buffs.has("shells_used"): return
	
	sender.add_buff("shells_used", 1)
	used = true
	var weapon: Item = sender.held.weapon
	
	if weapon.target == Item.Target.Single:
		for enemy in victim.team.boys_nodes:
			if enemy != victim:
				weapon.use_item(sender, enemy)
				if victim.team.is_evil:
					(enemy.held as Enemy).on_attacked(sender)
				sender.attacked.emit(enemy)
	
	sender.attacked.disconnect(_hit_everyone)

func on_level_up():
	super.on_level_up()
	extra_speed += 1
