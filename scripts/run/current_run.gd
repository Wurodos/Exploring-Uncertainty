extends Node

const save_path = "user://run.save"

var good_boys: Array[Slave] = []
var evil_boys: Array[Slave] = []

# var potential_team_1: Array[Slave] = []
# var potential_team_2: Array[Slave] = []

var inventory: Array[Item] = []

var craft_pool: Array[Item] = []
var craft_recipes: Array[Item] = []
var scraps: Dictionary[Item.Scrap, int] = {
	Item.Scrap.Flesh : 0,
	Item.Scrap.Gear : 0,
	Item.Scrap.Shard : 0,
	Item.Scrap.Tooth : 0,
	Item.Scrap.Oil : 0
}

var discounts : int = 0
var is_comms_repaired : bool = false
var is_in_purged: bool = false
var messages_not_seen: Array[int] = [0,1,2,3,4,5,6,7,8,9]
var elevators_repaired: int = 0

var state: Game.State = Game.State.Map

# deck will consist of 'cards' = enemy slaves or empty slots
# cherv camp =  3 (2 in 1st zone) battles back to back (waves)
# items are also in a deck, so no repeats until reshuffle
#
# ====== Zone 0 ======
# Only Chervs. Draw 4 cards
# DECK: CCCCCC--
# ITEM LVL: 1
# 2 weapons, 2 hats, 4 trinkets
# ====== Zone 1 ======
# Add Starrys (S) and Swirlys (W). Draw 3 cards
# DECK: CCCCCSSSWW--
# ITEM LVL: Half lvl 1, half lvl 2
# Swirlys always have a weapon (2) + 4 weapons
# 6 hats, 12 trinkets
# ====== Zone 2 ======
# Add Chomper (H) and Quagmire (Q). 4 cards
# DECK: CCCCSSSWWQQHH---
# ITEM LVL: Half lvl 2, half lvl 3
# Chompers dont have a weapon
# 8 weapons, 8 hats, 16 trinkets
# ====== Zone 3 ======
# TODO New enemies. 4 cards.
# DECK: CCCSSSSSWWWQQHH
# ITEM LVL: Half lvl 3, half lvl 4
# 8 weapons, 8 hats, 16 trinkets
# ====== Zone 4 ======
# All enemies have full equipment. 5 cards.
# DECK IS ENTIRELY RANDOM
# ITEM LVL: All lvl 4


var deck_0: Array[Slave] = []
var deck_1: Array[Slave] = []
var deck_2: Array[Slave] = []
var deck_3: Array[Slave] = []
var deck_4: Array[Slave] = []

var is_saved_game: bool = false
var is_tutorial: bool = false
var is_battle_tutorial: bool = false

var map_data: Dictionary = {}
var config: ConfigFile

func _ready() -> void:
	_load_config()
	
	TranslationServer.set_locale(config.get_value("prefs", "language"))
	
	
	randomize()
	_prepare_good_boys.call_deferred()
	_prepare_deck_0.call_deferred()
	_prepare_deck_1.call_deferred()
	_prepare_deck_2.call_deferred()
	_prepare_deck_3.call_deferred()
	
	
func _load_config() -> void:
	config = ConfigFile.new()
	var err = config.load("user://prefs.cfg")
	
	if err != OK:
		config.set_value("prefs", "language", "en")
		config.save("user://prefs.cfg")
		return

func save_game() -> void:
	var save_file : FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	var save_data = {
		"good_boys": good_boys.map(func(slave : Slave):
			return slave.serialize()),
		"inventory": inventory.map(func(item: Item):
			return item.serialize()),
		"discounts": discounts,
		"is_comms_repaired": is_comms_repaired,
		"map" : Map.instance.serialize()
	}

	save_file.store_line(JSON.stringify(save_data))
	
		
func has_save_file() -> bool:
	return FileAccess.file_exists(save_path)

func load_save() -> void:
	var save_file : FileAccess = FileAccess.open(save_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON PARSE ERROR: ", json.get_error_message())
			continue
		
		var data = json.data
		
		# Good boys
		good_boys = []
		for value in data["good_boys"]:
			good_boys.append(Slave.deserialize(value))
		
		# Discounts
		discounts = floor(data["discounts"])
		
		# Inventory
		inventory = []
		for value in data["inventory"]:
			inventory.append(Item.deserialize(value))
		
		# Flags
		is_comms_repaired = data["is_comms_repaired"]
		
		# Map
		map_data = data["map"]
		
		## DEBUG
		continue
		for value in data.values():
			if value is Array:
				for element in value:
					print(element)
			else: print(value)

func _prepare_good_boys() -> void:
	good_boys = [SlavePool.fetch("blob"), SlavePool.fetch("blob"), SlavePool.fetch("blob")]
	#good_boys[0].hp = 1

# FIXME pls no ugly code
# Here goes deck preparation
# If I find a more sophisticated and generalized method of doing this
# I'll fix it
# For now it's here and it's here to stay

func _prepare_deck_0() -> void:
	# items
	
	var weapons = []
	var hats = []
	var trinkets = []
	
	for i in range(2):
		weapons.append(ItemPool.fetch_random(Item.Type.Weapon))
		hats.append(ItemPool.fetch_random(Item.Type.Hat))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
	
	for i in range(4):
		weapons.append(ItemPool.fetch("no_weapon"))
		hats.append(ItemPool.fetch("no_hat"))
		trinkets.append(ItemPool.fetch("no_trinket"))
		trinkets.append(ItemPool.fetch("no_trinket"))
	
	weapons.shuffle()
	hats.shuffle()
	trinkets.shuffle()
	
	# slaves
	for i in range(6):
		var enemy = SlavePool.fetch("cherv")
		enemy.equip(weapons.pop_back())
		enemy.equip(hats.pop_back())
		enemy.equip(trinkets.pop_back(), 1)
		enemy.equip(trinkets.pop_back(), 2)
		
		deck_0.append(enemy)
	for i in range(2):
		deck_0.append(null)

	deck_0.shuffle()

func _prepare_deck_1() -> void:
	
	const chervs = 3
	const starrys = 5
	const swirlys = 2
	const all = chervs + starrys + swirlys
	const items = 4
	
	# items
	
	var weapons = []
	var hats = []
	var trinkets = []
	
	for i in range(items):
		weapons.append(ItemPool.fetch_random(Item.Type.Weapon))
		hats.append(ItemPool.fetch_random(Item.Type.Hat))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		
		if i < items / 2:
			(weapons[i] as Item).on_level_up()
			(hats[i] as Item).on_level_up()
			(trinkets[i*2] as Item).on_level_up()
			(trinkets[i*2+1] as Item).on_level_up()
	
	for i in range(all - items):
		weapons.append(ItemPool.fetch("no_weapon"))
		hats.append(ItemPool.fetch("no_hat"))
		trinkets.append(ItemPool.fetch("no_trinket"))
		trinkets.append(ItemPool.fetch("no_trinket"))
	
	weapons.shuffle()
	hats.shuffle()
	trinkets.shuffle()
	
	# slaves
	for i in range(10):
		var enemy : Slave
		var weapon: Item
		if i < 2:
			enemy = SlavePool.fetch("swirly")
			weapon = weapons.pop_at(weapons.find_custom(func(it: Item) : return it.is_item())) 
		elif i < 5+2: 
			enemy = SlavePool.fetch("starry")
			weapon = weapons.pop_back()
		else: 
			enemy = SlavePool.fetch("cherv")
			weapon = weapons.pop_back()
			
		enemy.equip(weapon)
		enemy.equip(hats.pop_back())
		enemy.equip(trinkets.pop_back(), 1)
		enemy.equip(trinkets.pop_back(), 2)
		deck_1.append(enemy)
	for i in range(2):
		deck_1.append(null)

	deck_1.shuffle()

func _prepare_deck_2() -> void:
	
	const chervs := 4
	const starrys := 3
	const quagmires := 2
	const chompers := 2
	const swirlys := 2
	const empty := 3
	const all := chervs + starrys + quagmires + chompers + swirlys
	const items := 8
	
	# items
	
	var weapons = []
	var hats = []
	var trinkets = []
	
	for i in range(items):
		weapons.append(ItemPool.fetch_random(Item.Type.Weapon))
		hats.append(ItemPool.fetch_random(Item.Type.Hat))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		
		
		(weapons[i] as Item).on_level_up()
		(hats[i] as Item).on_level_up()
		(trinkets[i*2] as Item).on_level_up()
		(trinkets[i*2+1] as Item).on_level_up()
		if i < items / 2:
			(weapons[i] as Item).on_level_up()
			(hats[i] as Item).on_level_up()
			(trinkets[i*2] as Item).on_level_up()
			(trinkets[i*2+1] as Item).on_level_up()
	
	for i in range(all - items):
		weapons.append(ItemPool.fetch("no_weapon"))
		hats.append(ItemPool.fetch("no_hat"))
		trinkets.append(ItemPool.fetch("no_trinket"))
		trinkets.append(ItemPool.fetch("no_trinket"))
	
	weapons.shuffle()
	hats.shuffle()
	trinkets.shuffle()
	
	# slaves
	for i in range(13):
		var enemy : Slave
		var weapon: Item
		if i < swirlys:
			enemy = SlavePool.fetch("swirly")
			weapon = weapons.pop_at(weapons.find_custom(func(it: Item) : return it.is_item())) 
		elif i < swirlys+chompers: 
			enemy = SlavePool.fetch("chomper")
			weapon = weapons.pop_at(weapons.find_custom(func(it: Item) : return not it.is_item())) 
		elif i < swirlys+chompers+quagmires: 
			enemy = SlavePool.fetch("quagmire")
			weapon = weapons.pop_back()
		elif i < swirlys+chompers+quagmires+starrys: 
			enemy = SlavePool.fetch("starry")
			weapon = weapons.pop_back()
		else: 
			enemy = SlavePool.fetch("cherv")
			weapon = weapons.pop_back()
			
		enemy.equip(weapon)
		enemy.equip(hats.pop_back())
		enemy.equip(trinkets.pop_back(), 1)
		enemy.equip(trinkets.pop_back(), 2)
		deck_2.append(enemy)
	for i in range(empty):
		deck_2.append(null)

	deck_2.shuffle()
	
func _prepare_deck_3() -> void:
	
	const chervs := 3
	const starrys := 5
	const quagmires := 2
	const chompers := 2
	const swirlys := 3
	const empty := 0
	const all := chervs + starrys + quagmires + chompers + swirlys
	const items := 8
	
	# items
	var weapons = []
	var hats = []
	var trinkets = []
	
	for i in range(items):
		weapons.append(ItemPool.fetch_random(Item.Type.Weapon))
		hats.append(ItemPool.fetch_random(Item.Type.Hat))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		
		for k in range(2):
			(weapons[i] as Item).on_level_up()
			(hats[i] as Item).on_level_up()
			(trinkets[i*2] as Item).on_level_up()
			(trinkets[i*2+1] as Item).on_level_up()
		if i < items / 2:
			(weapons[i] as Item).on_level_up()
			(hats[i] as Item).on_level_up()
			(trinkets[i*2] as Item).on_level_up()
			(trinkets[i*2+1] as Item).on_level_up()
	
	for i in range(all - items):
		weapons.append(ItemPool.fetch("no_weapon"))
		hats.append(ItemPool.fetch("no_hat"))
		trinkets.append(ItemPool.fetch("no_trinket"))
		trinkets.append(ItemPool.fetch("no_trinket"))
	
	weapons.shuffle()
	hats.shuffle()
	trinkets.shuffle()
	
	# slaves
	for i in range(all):
		var enemy : Slave
		var weapon: Item
		if i < swirlys:
			enemy = SlavePool.fetch("swirly")
			weapon = weapons.pop_at(weapons.find_custom(func(it: Item) : return it.is_item())) 
		elif i < swirlys + chompers: 
			enemy = SlavePool.fetch("chomper")
			weapon = weapons.pop_at(weapons.find_custom(func(it: Item) : return not it.is_item())) 
		elif i < swirlys + chompers + quagmires: 
			enemy = SlavePool.fetch("quagmire")
			weapon = weapons.pop_back()
		elif i < swirlys + chompers + quagmires + starrys: 
			enemy = SlavePool.fetch("starry")
			weapon = weapons.pop_back()
		else: 
			enemy = SlavePool.fetch("cherv")
			weapon = weapons.pop_back()
			
		enemy.equip(weapon)
		enemy.equip(hats.pop_back())
		enemy.equip(trinkets.pop_back(), 1)
		enemy.equip(trinkets.pop_back(), 2)
		deck_3.append(enemy)
	for i in range(empty):
		deck_3.append(null)

	deck_3.shuffle()

func _prepare_deck_4() -> void:
	
	const chervs := 3
	const starrys := 5
	const quagmires := 2
	const chompers := 2
	const swirlys := 3
	const empty := 0
	const all := chervs + starrys + quagmires + chompers + swirlys
	const items := 8
	
	# items
	var weapons = []
	var hats = []
	var trinkets = []
	
	for i in range(items):
		weapons.append(ItemPool.fetch_random(Item.Type.Weapon))
		hats.append(ItemPool.fetch_random(Item.Type.Hat))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		
		
		for k in range(3):
			(weapons[i] as Item).on_level_up()
			(hats[i] as Item).on_level_up()
			(trinkets[i*2] as Item).on_level_up()
			(trinkets[i*2+1] as Item).on_level_up()
	
	for i in range(all - items):
		weapons.append(ItemPool.fetch("no_weapon"))
		hats.append(ItemPool.fetch("no_hat"))
		trinkets.append(ItemPool.fetch("no_trinket"))
		trinkets.append(ItemPool.fetch("no_trinket"))
	
	weapons.shuffle()
	hats.shuffle()
	trinkets.shuffle()
	
	# slaves
	for i in range(all):
		var enemy : Slave
		var weapon: Item
		if i < swirlys:
			enemy = SlavePool.fetch("swirly")
			weapon = weapons.pop_at(weapons.find_custom(func(it: Item) : return it.is_item())) 
		elif i < swirlys + chompers: 
			enemy = SlavePool.fetch("chomper")
			weapon = weapons.pop_at(weapons.find_custom(func(it: Item) : return not it.is_item())) 
		elif i < swirlys + chompers + quagmires: 
			enemy = SlavePool.fetch("quagmire")
			weapon = weapons.pop_back()
		elif i < swirlys + chompers + quagmires + starrys: 
			enemy = SlavePool.fetch("starry")
			weapon = weapons.pop_back()
		else: 
			enemy = SlavePool.fetch("cherv")
			weapon = weapons.pop_back()
			
		enemy.equip(weapon)
		enemy.equip(hats.pop_back())
		enemy.equip(trinkets.pop_back(), 1)
		enemy.equip(trinkets.pop_back(), 2)
		deck_4.append(enemy)
	for i in range(empty):
		deck_4.append(null)

	deck_4.shuffle()

func arrange_evil_team(zone: int) -> Array[Slave]:
	
	var deck: Array[Slave]
	var draw_count: int = 0
	match(zone):
		0: 
			deck = deck_0
			draw_count = 4
		1: 
			deck = deck_1
			draw_count = 3
		2: 
			deck = deck_2
			draw_count = 4
		3: 
			deck = deck_3
			draw_count = 4
		4: 
			deck = deck_4
			draw_count = 5
	
	var team : Array[Slave] = []
	
	for i in range(draw_count):
		var enemy = deck.pop_back()
		if enemy != null:
			#enemy.hp = 1
			team.append(enemy)
	if deck.is_empty():
		match (zone): 
			0: _prepare_deck_0()
			1: _prepare_deck_1()
			2: _prepare_deck_2()
			3: _prepare_deck_3()
			4: _prepare_deck_4()
	
	
	if CurrentRun.is_battle_tutorial and team[0]:
		team[0].equip(ItemPool.fetch_random())
	return team

# Throws random item out if at 24
func put_item_in_inventory(item: Item) -> void:
	if CurrentRun.inventory.size() == 24:
		var id = randi_range(0, 23)
		SignalBus.lost_item.emit(CurrentRun.inventory.pop_at(id))
	
	CurrentRun.inventory.append(item)

func arrange_boss() -> void:
	CurrentRun.evil_boys = [ReptilePool.fetch("roots_and_toots")]
	# CurrentRun.evil_boys[0].hp = 1
