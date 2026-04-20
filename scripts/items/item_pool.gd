extends Node

class TierPool:
	var weapons : Array[Item] = []
	var hats : Array[Item] = []
	var trinkets : Array[Item] = []
	var actual_items : Array[Item] = []


var _pool : Dictionary[StringName, Item]
var _tier_pools: Array[TierPool] = []

func _ready() -> void:
	_tier_pools.append(null)
	for tier in range(1,4):
		_tier_pools.append(TierPool.new())
		for subfolder in ["weapons", "trinkets", "hats"]:
			var path = "res://pool/items/tier" + str(tier) + "/" + subfolder
			var dir_access : DirAccess = DirAccess.open(path)
			var files : PackedStringArray = dir_access.get_files()
			
			for file_name : String in files:
				var loaded : Item = load((path+"/"+file_name).trim_suffix(".remap"))
				loaded.u_name = file_name.trim_suffix(".remap")
				loaded.u_name = loaded.u_name.trim_suffix(".tres")
				
				loaded.localize()
				_pool[loaded.u_name] = loaded
				
				if loaded.is_item():
					match(loaded.type):
						Item.Type.Weapon: _tier_pools[tier].weapons.append(loaded)
						Item.Type.Hat:  _tier_pools[tier].hats.append(loaded)
						Item.Type.Trinket:  _tier_pools[tier].trinkets.append(loaded)
					_tier_pools[tier].actual_items.append(loaded)
				
				print("ITEM_POOL: Loaded " + loaded.u_name + " successfully")

func get_all(type: Item.Type = Item.Type.All, tier: int = 1) -> Array[Item]:
	match(type):
		Item.Type.Weapon: return  _tier_pools[tier].weapons.duplicate()
		Item.Type.Hat: return  _tier_pools[tier].hats.duplicate()
		Item.Type.Trinket: return  _tier_pools[tier].trinkets.duplicate()
		Item.Type.All: return  _tier_pools[tier].actual_items.duplicate()
	return []

func fetch(item_name: StringName) -> Item:
	return _pool[item_name].duplicate()

func has(item_name: StringName) -> bool:
	return _pool.has(item_name)

func fetch_random(type: Item.Type = Item.Type.All, tier: int = 1) -> Item:
	match(type):
		Item.Type.Weapon: return  _tier_pools[tier].weapons.pick_random().duplicate()
		Item.Type.Hat: return  _tier_pools[tier].hats.pick_random().duplicate()
		Item.Type.Trinket: return  _tier_pools[tier].trinkets.pick_random().duplicate()
		Item.Type.All: return  _tier_pools[tier].actual_items.pick_random().duplicate()
	push_error("Item Type not recognized when fetching random")
	return null
