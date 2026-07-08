extends Resource

class_name Slave

enum SpriteSize {
	Normal,
	Big,
	Huge,
	TwoHead
}

@export var u_name: StringName
@export var base_maxhp: int
@export var base_speed: int
@export var base_cost: int = 0
@export var sprite_size: SpriteSize
@export var texture: Texture2D
@export var unique_visual: PackedScene = null
@export var quirks: Array[Quirk]
@export var default_weapon: String = "no_weapon"
@export var item_rate_if_reinforced: float = 0.5

var hp : int
var maxhp : int

var heal_receive: int = 0
var heal_give: int = 0


var speed : int
var weapon: Item
var hat: Item
var trinket1 : Item

var trinket2 : Item
var trinket3 : Item

var is_evil : bool
var is_alive : bool
var allow_3_trinkets: bool = false

signal item_equipped(item: Item)
signal item_unequipped(item: Item)

func localize() -> void:
	pass

func reinit() -> void:
	hp = base_maxhp
	maxhp = base_maxhp
	speed = base_speed
	
	weapon = get_default_weapon()
	hat = ItemPool.fetch("no_hat")
	trinket1 = ItemPool.fetch("no_trinket")
	trinket2 = ItemPool.fetch("no_trinket")
	trinket3 = ItemPool.fetch("no_trinket")
	localize()

func serialize() -> Dictionary:
	return {
		"u_name": u_name,
		"maxhp": maxhp,
		"hp": hp,
		"weapon": weapon.serialize(),
		"hat": hat.serialize(),
		"trinket1": trinket1.serialize(),
		"trinket2": trinket2.serialize()
	}

static func deserialize(data: Dictionary) -> Slave:
	var slave = SlavePool.fetch(data["u_name"])
	
	slave.maxhp = data["maxhp"]
	slave.hp = data["hp"]
	
	slave.weapon = Item.deserialize(data["weapon"])
	slave.hat = Item.deserialize(data["hat"])
	slave.trinket1 = Item.deserialize(data["trinket1"])
	slave.trinket2 = Item.deserialize(data["trinket2"])
	return slave


func _init() -> void:
	SignalBus.locale_changed.connect(localize)
	
	is_evil = false
	is_alive = true
	
	hp = base_maxhp
	maxhp = base_maxhp
	
	speed = base_speed
	
	weapon = get_default_weapon()
	hat = ItemPool.fetch("no_hat")
	trinket1 = ItemPool.fetch("no_trinket")
	trinket2 = ItemPool.fetch("no_trinket")
	trinket3 = ItemPool.fetch("no_trinket")

func undress() -> Array[Item]:
	var old_items : Array[Item] = []
	
	if weapon.extra_hp < hp:
		old_items.append(equip(get_default_weapon()))
	if trinket3.extra_hp < hp:
		old_items.append(equip(ItemPool.fetch("no_trinket"), 3))
	if hat.extra_hp < hp:
		old_items.append(equip(ItemPool.fetch("no_hat")))
	if trinket1.extra_hp < hp:
		old_items.append(equip(ItemPool.fetch("no_trinket"), 1))
	if trinket2.extra_hp < hp:
		old_items.append(equip(ItemPool.fetch("no_trinket"), 2))
	
	return old_items

func get_item(item_type: Item.Type, trinket_id: int = 1) -> Item:
	match(item_type):
		Item.Type.Weapon: return weapon
		Item.Type.Hat: return hat
		Item.Type.Trinket:
			if trinket_id == 1: return trinket1
			elif trinket_id == 2: return trinket2
			elif trinket_id == 3: return trinket3
	return weapon

func get_extra_item() -> Item:
	return null	

func get_all_items() -> Array[Item]:
	return [weapon, hat, trinket1, trinket2, trinket3]

# base_cost = 5 + base_hp/2
# + costs of items
# 70%-100% price depending on percentage of health

func get_cost() -> int:
	var total : int = base_cost + 5 + base_maxhp / 2
	for item: Item in get_all_items():
		total += item.cost	
	return floor(total * lerp(0.7, 1.0, (hp / float(maxhp))))

func equip(item: Item, trinket_id: int = -1) -> Item:
	var old_item: Item
	match(item.type):
		Item.Type.Weapon:
			old_item = weapon
			weapon = item
		Item.Type.Hat:
			old_item = hat
			hat = item
		Item.Type.Trinket:
			if trinket_id == -1:
				trinket_id = 1
				if trinket1.is_item(): trinket_id += 1
				if trinket2.is_item(): trinket_id += 1
				if trinket_id == 3 and (trinket3.is_item() or not allow_3_trinkets): trinket_id = 1
			
			if trinket_id == 1:
				old_item = trinket1
				trinket1 = item
			elif trinket_id == 2:
				old_item = trinket2
				trinket2 = item
			elif trinket_id == 3:
				old_item = trinket3
				trinket3 = item
				
	old_item.on_unequip(self)
	var slave_node: SlaveNode = null
	if Battle.instance: slave_node = Battle.instance.find_slave_node(self)
	if slave_node: old_item.on_unequip_battle(slave_node)
	item.on_equip(self)
	if slave_node: item.on_equip_battle(Battle.instance.find_slave_node(self))
	item_equipped.emit(item)
	item_unequipped.emit(old_item)
	
	return old_item

func add_received_damage(source: SlaveNode, harm: int) -> int:
	return harm

func multiply_received_damage(source: SlaveNode, harm: int) -> int:
	return harm

func on_death() -> void:
	pass

func get_default_weapon() -> Item:
	return ItemPool.fetch(default_weapon)

func unequip(item: Item) -> void:
	var id = get_all_items().find(item)
	match(id):
		0: equip(get_default_weapon())
		1: equip(ItemPool.fetch("no_hat"))
		2: equip(ItemPool.fetch("no_trinket"), 1)
		3: equip(ItemPool.fetch("no_trinket"), 2)

func on_start_battle(_node: SlaveNode) -> void:
	pass

func debug() -> void:
	print("-----")
	print(u_name)
	print(weapon.name)
	print(hat.name)
	print(trinket1.name)
	print(trinket2.name)
