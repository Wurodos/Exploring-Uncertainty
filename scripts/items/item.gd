extends Resource

class_name Item

enum Scrap {
	Flesh, Gear, Shard, Tooth, Oil
}
enum Type { Weapon, Hat, Trinket, All}
enum Target { Single, AllTeam, Self, None}
enum Enchant { None, Red, Blue, Green, Yellow }

@export var type : Type
@export var target: Target
@export var extra_hp : int
@export var extra_speed: int = 0 
@export var texture: Texture2D
@export var cost: int
@export var craft_reqs : Dictionary[Scrap, int] = {}
@export var keywords: Array[String] = []

@export var u_name: StringName = ""
@export var name: String = ""
@export var desc: String = ""

var enchant : Enchant = Enchant.None
var level : int = 1
var experience : int = 0
var is_recipe: bool = false

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

static func random_scrap() -> Scrap:
	return [Scrap.Flesh, Scrap.Gear, Scrap.Shard, Scrap.Tooth, Scrap.Oil].pick_random()

func get_scrap() -> Item.Scrap:
	var r = randi_range(0, 99)
	match(type):
		Type.Weapon:
			if r < 20: return Item.Scrap.Flesh
			if r < 60: return Item.Scrap.Tooth
			return Item.Scrap.Shard
		Type.Hat:
			if r < 20: return Item.Scrap.Gear
			if r < 60: return Item.Scrap.Tooth
			return Item.Scrap.Flesh
		Type.Trinket:
			if r < 20: return Item.Scrap.Oil
			if r < 60: return Item.Scrap.Shard
			return Item.Scrap.Gear
			
	# v Should never happen v
		Type.All:
			push_error("Item Type is ALL")
			return Item.Scrap.Oil
	push_error("Item Type is unrecognized")
	return Item.Scrap.Oil
	

func is_item() -> bool:
	return u_name != "no_weapon" and u_name != "no_hat"\
		and u_name != "no_trinket"

func use_item(_sender: SlaveNode, _victim: SlaveNode):
	pass


#Override this. Irrelevant for trinkets (for now)
#Should be called on every member of player's team
#Higher number -> more likely to pick. Typically -3 to +3
#-999 = never pick
#+999 = always pick
func get_priority(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return -999

func get_intention() -> Enemy.Intention:
	return null

func on_equip(owner: Slave):
	owner.maxhp += extra_hp
	owner.hp += extra_hp

func on_unequip(owner: Slave):
	owner.maxhp -= extra_hp
	owner.hp -= extra_hp

func on_level_up():
	print("level up!")
	localize()

func on_start_battle(owner: SlaveNode):
	owner.set_speed(extra_speed)
