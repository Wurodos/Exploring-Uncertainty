extends Enemy

var hat_extra: Item

func _init() -> void:
	super._init()

func localize() -> void:
	super.localize()

func update_stats(node: SlaveNode) -> void:
	super.update_stats(node)
	hat_extra = ItemPool.fetch_random(Item.Type.Hat)
	hat_extra.on_equip(self)
	item_equipped.emit(hat_extra)
	node.reapply()
	localize()

func get_all_items() -> Array[Item]:
	return [weapon, hat, trinket1, trinket2, hat_extra]

func get_extra_item() -> Item:
	return hat_extra

# Support. Always wears 2 hats!
# 1. Only quagmires or (if somehow removed) no hats = Run
# 2. Holds weapon = Give it to healthiest ally
# 3. Use hat with higher priority.

func _transfer_weapon(ally: SlaveNode):
	if not ally.held.is_alive: return
	ally.held.equip(owner.held.weapon)
	ally.reapply()
	owner.held.unequip(owner.held.weapon)
	owner.reapply()

func decide_intention() -> void:
	super.decide_intention()
	
	var alive = 0
	var quags = 0
	for slave in owner.team.boys:
		if slave.is_alive: alive += 1
		if slave.u_name == u_name: quags += 1
	if alive == quags or (not hat.is_item() and not hat_extra.is_item()):
		_intention_run()
		return
	
	if weapon.is_item():
		var allies_no_weapon: Array[SlaveNode] = owner.team.boys_nodes\
			.filter(func(node: SlaveNode): return not node.held.weapon.is_item())
		if allies_no_weapon.size() > 0:
			var target := 0
			for i in range(owner.team.boys_nodes.size()):
				if owner.team.boys_nodes[target].held.hp > owner.team.boys_nodes[i].held.hp:
					target = i
			intention = Intention.new(Intention.Type.Support)
			intention.is_support = true
			intention.targets = [target]
			intention.effect = _transfer_weapon
			return
	
	var hat_target: int = -1
	var is_extra: bool = false
	var max_priority: int = -2
	for i in range(Battle.instance.evil_team.boys_nodes.size()):
		var slave = Battle.instance.evil_team.boys_nodes[i]
		var priority = hat.get_priority(owner, slave)
		if owner == slave: priority -= 1
		if not (hat.target == Item.Target.Self and owner != slave):
			if priority > max_priority:
				max_priority = priority
				is_extra = false
				hat_target = i
		priority = hat_extra.get_priority(owner, slave)
		if owner == slave: priority -= 1
		if not (hat_extra.target == Item.Target.Self and owner != slave):
			if priority > max_priority:
				max_priority = priority
				is_extra = true
				hat_target = i
	
	if hat_target != -1:
		if is_extra:
			intention = hat_extra.get_intention(owner)
		else:	intention = hat.get_intention(owner)
		
		if intention.targets.is_empty():
			intention.targets = [hat_target]
	else:
		_intention_run()
