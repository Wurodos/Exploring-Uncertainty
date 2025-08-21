extends Node

const save_path = "user://run.save"

var good_boys: Array[Slave] = []
var evil_boys: Array[Slave] = []
var inventory: Array[Item] = []

var discounts : int = 0
var messages_not_seen: Array[int] = [0,1,2,3,4,5,6,7,8,9]

var state: Game.State = Game.State.Map

# deck will consist of 'cards' = enemy slaves or empty slots
# when card is removed, another is shuffled from archive 
# tough battles are basically 3 next cards from archive
#
# starting deck:
# 	16 cherv, 8 empty
# 	4 hats, 4 weapons, 8 trinkets
#
# archive:
#	x4 starry, x2 quagmire, x2 swirly, x1 chomper, 3 empty shuffled
#	4 hats, 4 weapons, 8 trinkets


var evil_deck: Array[Slave] = []
var evil_archive: Array[Slave] = []
var archive_level: int = 0

var is_saved_game: bool = false
var is_tutorial: bool = false

var map_data: Dictionary = {}
var config: ConfigFile

func _ready() -> void:
	_load_config()
	
	TranslationServer.set_locale(config.get_value("prefs", "language"))
	
	
	randomize()
	_prepare_good_boys.call_deferred()
	_prepare_deck.call_deferred()
	_prepare_archive.call_deferred()
	
	
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
		"evil_deck": evil_deck.map(func(slave : Enemy):
			if not slave: return null
			else: return slave.serialize()),
		"evil_archive": evil_archive.map(func(slave : Enemy):
			if not slave: return null
			else: return slave.serialize()),
		"archive_level": archive_level,
		"discounts": discounts,
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
		
		# Evil deck
		evil_deck = []
		for value in data["evil_deck"]:
			if value == null: evil_deck.append(null)
			else: evil_deck.append(Enemy.deserialize(value))
		
		# Evil archive
		evil_archive = []
		for value in data["evil_archive"]:
			if value == null: evil_archive.append(null)
			else: evil_archive.append(Enemy.deserialize(value))
		
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
		print(inventory.size())
		
		# Archive level
		archive_level = floor(data["archive_level"])
		
		# Map
		map_data = data["map"]
		
		## DEBUG
		continue
		for value in data.values():
			if value is Array:
				for element in value:
					print(element)
			else: print(value)
	
	
	## DEBUG
	return
	# Deck
	for enemy in evil_deck:
		if not enemy: 
			print("\n EMPTY SLOT")
			continue
		print("\n" + enemy.u_name)
		print(enemy.weapon.name)
		print(enemy.hat.name)
		print(enemy.trinket1.name)
		print(enemy.trinket2.name)

func _prepare_good_boys() -> void:
	good_boys = [SlavePool.fetch("blob"), SlavePool.fetch("blob"), SlavePool.fetch("blob")]
	
	#good_boys[0].equip(ItemPool.fetch("alcohol"))
	#good_boys[0].equip(ItemPool.fetch("crown"))
	#good_boys[1].equip(ItemPool.fetch("crown"))
	#good_boys[2].equip(ItemPool.fetch("crown"))
	#good_boys[0].hp = 1
	#good_boys[0].speed = -3

func _prepare_deck() -> void:
	# items
	
	var weapons = []
	var hats = []
	var trinkets = []
	
	for i in range(4):
		weapons.append(ItemPool.fetch_random(Item.Type.Weapon))
		hats.append(ItemPool.fetch_random(Item.Type.Hat))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
	
	for i in range(12):
		weapons.append(ItemPool.fetch("no_weapon"))
		hats.append(ItemPool.fetch("no_hat"))
		trinkets.append(ItemPool.fetch("no_trinket"))
		trinkets.append(ItemPool.fetch("no_trinket"))
	
	weapons.shuffle()
	hats.shuffle()
	trinkets.shuffle()
	
	# slaves
	for i in range(16):
		var enemy = SlavePool.fetch("cherv")
		enemy.equip(weapons.pop_back())
		enemy.equip(hats.pop_back())
		enemy.equip(trinkets.pop_back(), 1)
		enemy.equip(trinkets.pop_back(), 2)
		
		evil_deck.append(enemy)
	for i in range(8):
		evil_deck.append(null)

	evil_deck.shuffle()

func _prepare_archive() -> void:
	archive_level += 1
	
	var weapons = []
	var hats = []
	var trinkets = []
	
	for i in range(min(1 + archive_level, 9)):
		weapons.append(ItemPool.fetch_random(Item.Type.Weapon))
		hats.append(ItemPool.fetch_random(Item.Type.Hat))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
		trinkets.append(ItemPool.fetch_random(Item.Type.Trinket))
	
	for i in range(max(8 - archive_level, 0)):
		weapons.append(ItemPool.fetch("no_weapon"))
		hats.append(ItemPool.fetch("no_hat"))
		trinkets.append(ItemPool.fetch("no_trinket"))
		trinkets.append(ItemPool.fetch("no_trinket"))
	
	for i in range(3):
		evil_archive.append(null)
	evil_archive.append_array([SlavePool.fetch("starry"), SlavePool.fetch("starry"),
		SlavePool.fetch("starry"), SlavePool.fetch("starry"),
		SlavePool.fetch("quagmire"), SlavePool.fetch("quagmire"),
		SlavePool.fetch("swirly"), SlavePool.fetch("swirly"),
		SlavePool.fetch("chomper")
	])
	
	weapons.shuffle()
	hats.shuffle()
	trinkets.shuffle()
	
	for slave : Slave in evil_archive:
		if slave == null: continue
		
		slave.equip(weapons.pop_back())
		slave.equip(hats.pop_back())
		slave.equip(trinkets.pop_back(), 1)
		slave.equip(trinkets.pop_back(), 2)
	
	evil_archive.shuffle()
	
	#for slave : Slave in evil_archive:
	#	if slave == null:
	#		print("-------")
	#		print("NO SLAVE")
	#	else: slave.debug()

func arrange_evil_team() -> void:
	##	Debug
	#CurrentRun.evil_boys = [ReptilePool.fetch("roots_and_toots")]
	#return
	
	CurrentRun.evil_boys = []
	
	for i in range(3):
		var enemy = evil_deck.pop_back()
		if enemy != null:
			CurrentRun.evil_boys.append(enemy)
	
	for i in range(3):
		evil_deck.append(evil_archive.pop_back())
		if evil_archive.is_empty():
			_prepare_archive()
	evil_deck.shuffle()
	
	# if 3 empties are in row
	if CurrentRun.evil_boys.is_empty():
		var enemy = SlavePool.fetch("cherv")
		enemy.equip(ItemPool.fetch_random(Item.Type.Weapon))
		enemy.equip(ItemPool.fetch_random(Item.Type.Hat))
		enemy.equip(ItemPool.fetch_random(Item.Type.Trinket), 1)
		enemy.equip(ItemPool.fetch_random(Item.Type.Trinket), 2)
		CurrentRun.evil_boys.append(enemy)

# Throws random item out if at 24
func put_item_in_inventory(item: Item) -> void:
	if CurrentRun.inventory.size() == 24:
		var id = randi_range(0, 23)
		SignalBus.lost_item.emit(CurrentRun.inventory.pop_at(id))
	
	CurrentRun.inventory.append(item)

func arrange_difficult() -> void:
	CurrentRun.evil_boys = []
	for i in range(3):
		evil_deck.append(evil_archive.pop_back())
		if evil_archive.is_empty():
			_prepare_archive()
	
	for i in range(3):
		var enemy = evil_deck.pop_back()
		if enemy != null:
			CurrentRun.evil_boys.append(enemy)
	
	if CurrentRun.evil_boys.is_empty():
		var enemy = SlavePool.fetch("cherv")
		enemy.equip(ItemPool.fetch_random(Item.Type.Weapon))
		enemy.equip(ItemPool.fetch_random(Item.Type.Hat))
		enemy.equip(ItemPool.fetch_random(Item.Type.Trinket))
		enemy.equip(ItemPool.fetch_random(Item.Type.Trinket))
		CurrentRun.evil_boys.append(enemy)

func arrange_boss() -> void:
	CurrentRun.evil_boys = [ReptilePool.fetch("roots_and_toots")]
	# CurrentRun.evil_boys[0].hp = 1
