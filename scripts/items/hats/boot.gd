extends Item

@export var heal: int = 2
@export var harm: int = 4

var sender: Slave

func localize():
	super.localize()
	desc = desc.format([heal, harm], "{}")

func on_equip(owner: Slave):
	super.on_equip(owner)
	sender = owner
	SignalBus.entered_room.connect(_check_and_heal)

func on_unequip(owner: Slave):
	super.on_unequip(owner)
	SignalBus.entered_room.disconnect(_check_and_heal)

func _check_and_heal(room: Room):
	if sender.is_alive and room.type == Room.Type.Empty:
		sender.hp = min(sender.maxhp, sender.hp + heal)
		SignalBus.refresh.emit()

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	Action.deal_damage(sender, ally, harm)
	
	var victim : SlaveNode = Battle.instance.evil_team.boys_nodes.filter(func(enemy: SlaveNode): return enemy.held.is_alive).pick_random()
	ally.held.weapon.use_item(ally, victim)
