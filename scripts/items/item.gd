extends Resource

class_name Item

enum Type { Weapon, Hat, Trinket, All}
enum Target { Single, AllTeam, Self, None}
enum Enchant { None, Red, Blue, Green, Yellow }

@export var type : Type
@export var target: Target
@export var extra_hp : int
@export var extra_speed: int = 0 
@export var texture: Texture2D
@export var cost: int
@export var keywords: Array[String] = []

@export var u_name: StringName = ""
@export var name: String = ""
@export var desc: String = ""

var enchant : Enchant = Enchant.None

func _init() -> void:
	SignalBus.locale_changed.connect(localize)

func localize() -> void:
	name = tr(u_name + "_name")
	desc = tr(u_name + "_desc")

func serialize() -> Dictionary:
	return {
		"u_name": u_name,
		"cost": cost,
		"enchant": enchant
	}

static func deserialize(data: Dictionary) -> Item:
	var item = ItemPool.fetch(data["u_name"])
	item.cost = floor(data["cost"])
	item.enchant = data["enchant"]
	return item

func is_item() -> bool:
	return u_name != "no_weapon" and u_name != "no_hat"\
		and u_name != "no_trinket"

func use_item(_sender: SlaveNode, _victim: SlaveNode):
	pass

func on_equip(owner: Slave):
	owner.maxhp += extra_hp
	owner.hp += extra_hp

func on_unequip(owner: Slave):
	owner.maxhp -= extra_hp
	owner.hp -= extra_hp
	
func on_start_battle(owner: SlaveNode):
	owner.set_speed(extra_speed)
	print(name)
