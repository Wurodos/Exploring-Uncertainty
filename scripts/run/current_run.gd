extends Node

var good_boys: Array[Slave] = []
var evil_boys: Array[Slave] = []
var inventory: Array[Item] = []

var discounts : int = 0

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

var config: ConfigFile

func _ready() -> void:
	_load_config()
	
	TranslationServer.set_locale(config.get_value("prefs", "language"))
	
	randomize()
	_prepare_deck.call_deferred()
	_prepare_archive.call_deferred()
	
	
func _load_config() -> void:
	config = ConfigFile.new()
	var err = config.load("user://prefs.cfg")
	
	if err != OK:
		config.set_value("prefs", "language", "en")
		config.save("user://prefs.cfg")
		return



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
	#CurrentRun.evil_boys = [SlavePool.fetch("swirly")]
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
		enemy.equip(ItemPool.fetch_random(Item.Type.Trinket))
		enemy.equip(ItemPool.fetch_random(Item.Type.Trinket))
		CurrentRun.evil_boys.append(enemy)

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
