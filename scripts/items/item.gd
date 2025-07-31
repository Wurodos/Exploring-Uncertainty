extends Resource

class_name Item

enum Type { Weapon, Hat, Trinket, All}
enum Target { Single, AllTeam, Self, None}
enum Enchant { None, Red, Blue, Green, Yellow }

@export var u_name: StringName
@export var name: String
@export_multiline var desc: String
@export var type : Type
@export var target: Target
@export var extra_hp : int
@export var extra_speed: int = 0 
@export var texture: Texture2D
@export var cost: int

var enchant : Enchant = Enchant.None

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
