extends Node

var _pool : Dictionary[StringName, Item]

func _ready() -> void:
	for subfolder in ["weapons", "trinkets", "hats"]:
		var dir_access : DirAccess = DirAccess.open("res://pool/items/"+subfolder)
		var files : PackedStringArray = dir_access.get_files()
		
		for file_name : String in files:
			var loaded : Item = load("res://pool/items/" + subfolder + "/" + file_name)
			_pool[loaded.u_name] = loaded
			print("ITEM_POOL: Loaded " + loaded.u_name + " successfully")

func fetch(item_name: StringName) -> Item:
	return _pool[item_name].duplicate()
