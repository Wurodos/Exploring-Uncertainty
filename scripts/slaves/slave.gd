extends Resource

class_name Slave

@export var u_name: StringName
@export var base_maxhp: int
@export var base_speed: int
@export var texture: Texture2D

var hp : int
var maxhp : int

var speed : int

var weapon: Item
var hat: Item
var trinket1 : Item
var trinket2 : Item

var is_evil : bool
var is_alive : bool

func reinit() -> void:
	hp = base_maxhp
	maxhp = base_maxhp
	speed = base_speed

func _init() -> void:
	is_evil = false
	is_alive = true
	
	hp = base_maxhp
	maxhp = base_maxhp
	
	speed = base_speed
	
	weapon = ItemPool.fetch("no_weapon")
	hat = ItemPool.fetch("no_hat")
	trinket1 = ItemPool.fetch("no_trinket")
	trinket2 = ItemPool.fetch("no_trinket")

func get_item(item_type: Item.Type, trinket_id: int = 1) -> Item:
	match(item_type):
		Item.Type.Weapon: return weapon
		Item.Type.Hat: return hat
		Item.Type.Trinket:
			if trinket_id == 1: return trinket1
			else: return trinket2
	return weapon

func equip(item: Item, trinket_id: int = 1) -> Item:
	var old_item: Item
	match(item.type):
		Item.Type.Weapon:
			old_item = weapon
			weapon = item
		Item.Type.Hat:
			old_item = hat
			hat = item
		Item.Type.Trinket:
			if trinket_id == 1:
				old_item = trinket1
				trinket1 = item
			else:
				old_item = trinket2
				trinket2 = item
				
	old_item.on_unequip(self)	
	item.on_equip(self)
	
	return old_item
