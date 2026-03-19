extends Item

func localize():
	super.localize()

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.tags.append(Action.TAG_STATIC_HEALTH)

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	if ally.held.hat.u_name != u_name:
		ally.held.hat.use_item(ally, sender)

func on_equip(owner: Slave):
	super.on_equip(owner)
	owner.allow_3_trinkets = true

func on_unequip(owner: Slave):
	super.on_unequip(owner)
	owner.allow_3_trinkets = false
	var held_trinket: Item = owner.equip(ItemPool.fetch("no_trinket"), 3)
	if held_trinket.is_item():
		CurrentRun.put_item_in_inventory(held_trinket)

func on_level_up():
	super.on_level_up()
	extra_hp += 5

func get_priority(sender: SlaveNode, ally: SlaveNode) -> int:
	if not ally.held.is_alive: return -999
	if ally.held.hat.u_name == u_name: return -999
	
	return ally.held.hat.get_priority(ally, sender)

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
