extends Node

var _pool : Dictionary[StringName, Item]

var _weapons : Array[Item] = []
var _hats : Array[Item] = []
var _trinkets : Array[Item] = []
var _actual_items : Array[Item] = []

func _ready() -> void:
	for subfolder in ["weapons", "trinkets", "hats"]:
		var dir_access : DirAccess = DirAccess.open("res://pool/items/"+subfolder)
		var files : PackedStringArray = dir_access.get_files()
		
		for file_name : String in files:
			var loaded : Item = load("res://pool/items/" + subfolder + "/" + file_name)
			_pool[loaded.u_name] = loaded
			
			if loaded.is_item():
				match(loaded.type):
					Item.Type.Weapon: _weapons.append(loaded)
					Item.Type.Hat: _hats.append(loaded)
					Item.Type.Trinket: _trinkets.append(loaded)
				_actual_items.append(loaded)
			
			print("ITEM_POOL: Loaded " + loaded.u_name + " successfully")

func fetch(item_name: StringName) -> Item:
	return _pool[item_name].duplicate()

func fetch_random(type: Item.Type = Item.Type.All) -> Item:
	match(type):
		Item.Type.Weapon: return _weapons.pick_random().duplicate()
		Item.Type.Hat: return _hats.pick_random().duplicate()
		Item.Type.Trinket: return _trinkets.pick_random().duplicate()
		Item.Type.All: return _actual_items.pick_random().duplicate()
	push_error("Item Type not recognized when fetching random")
	return null
