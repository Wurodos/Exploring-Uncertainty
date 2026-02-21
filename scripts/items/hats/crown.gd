extends Item

@export var speed_loss: int = 1
var owner_saved: Slave

func localize():
	super.localize()
	desc = desc.format([speed_loss], "{}")

func bonus_health(item: Item):
	if item.type == Item.Type.Trinket:
		owner_saved.maxhp += item.extra_hp
		owner_saved.hp += item.extra_hp

func less_health(item: Item):
	if item.type == Item.Type.Trinket:
		owner_saved.maxhp -= item.extra_hp
		owner_saved.hp -= item.extra_hp

func on_equip(owner: Slave):
	super.on_equip(owner)
	
	owner.item_equipped.connect(bonus_health)
	owner.item_unequipped.connect(less_health)
	var sum = owner.trinket1.extra_hp + owner.trinket2.extra_hp
	owner.maxhp += sum
	owner.hp += sum
	owner_saved = owner

func on_unequip(owner: Slave):
	super.on_unequip(owner)
	owner.item_equipped.disconnect(bonus_health)
	owner.item_unequipped.disconnect(less_health)
	var sum = owner.trinket1.extra_hp + owner.trinket2.extra_hp
	owner.maxhp -= sum
	owner.hp -= sum


func use_item(_sender: SlaveNode, ally: SlaveNode):
	ally.set_speed(-speed_loss)

func on_level_up():
	extra_hp += 5
	extra_speed -= 1
	super.on_level_up()

func get_priority(_sender: SlaveNode, _ally: SlaveNode) -> int:
	return -999

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.Support)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
