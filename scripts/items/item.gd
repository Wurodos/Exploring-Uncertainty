extends Resource

class_name Item

enum Scrap {
	Flesh, Gear, Shard, Tooth, Oil
}
enum Type { Weapon, Hat, Trinket, All}
enum Target { Single, AllTeam, Self, None}
enum Enchant { None, Red, Blue, Green, Yellow }

@export var tier : int = 1
@export var type : Type
@export var target: Target
@export var extra_hp : int
@export var extra_speed: int = 0 
@export var texture: Texture2D
@export var cost: int
@export var craft_reqs : Dictionary[Scrap, int] = {}
@export var craft_items: Array[Item] = []
@export var keywords: Array[String] = []

@export_category("Flags")
@export var is_melee: bool = true
@export var possible_enemy_item: bool = true

@export_category("Outdated")
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

func consume(sender: SlaveNode) -> void:
	sender.remove_item(u_name)
	sender.consumed.emit(self)

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
	
# Slave is needed if item is currently equipped
func gain_exp(slave: Slave = null) -> void:
	if is_item() and level < 5:
		experience += 1
		if experience == Constants.exp_required[level-1]:
			level_up(slave)

func level_up(slave: Slave = null) -> void:
	if slave: slave.unequip(self)
	on_level_up()
	if slave: 
		if not slave.trinket1.is_item():
			slave.equip(self, 1)
		elif not slave.trinket2.is_item():
			slave.equip(self, 2)
		elif slave.allow_3_trinkets:
			slave.equip(self, 3)
		else:
			slave.equip(self)
			
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

# Purely used for weapons by enemies
# Yields average/potential harm for non-standard weapons
func get_harm() -> int:
	return 0

func get_displayed_harm(_sender: SlaveNode, _victim: SlaveNode) -> int:
	return get_harm()

func get_intention(_sender: SlaveNode) -> Enemy.Intention:
	return null

func on_sold(_room: Room) -> void:
	pass

func on_equip(owner: Slave):
	owner.maxhp += extra_hp
	owner.hp += extra_hp

func on_unequip(owner: Slave):
	owner.maxhp -= extra_hp
	owner.hp -= extra_hp

func on_equip_battle(owner: SlaveNode):
	owner.set_speed(extra_speed)
	

func on_unequip_battle(owner: SlaveNode):
	owner.set_speed(-extra_speed)


func on_level_up():
	experience = 0
	level += 1
	cost += 3
	localize.call_deferred()

func on_start_battle(owner: SlaveNode):
	owner.set_speed(extra_speed)

func on_end_battle(owner: Slave):
	pass
