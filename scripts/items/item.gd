extends Resource

class_name Item

enum Type { Weapon, Hat, Trinket}
enum Target { Single, AllTeam, Self}

@export var u_name: StringName
@export var name: String
@export_multiline var desc: String
@export var type : Type
@export var target: Target
@export var extra_hp : int
@export var texture: Texture2D

func use_item(_sender: SlaveNode, _victim: SlaveNode):
	pass

func on_equip(owner: Slave):
	owner.maxhp += extra_hp
	owner.hp += extra_hp

func on_unequip(owner: Slave):
	owner.maxhp -= extra_hp
	owner.hp -= extra_hp
	
func on_start_battle(_owner: SlaveNode):
	print(name)
