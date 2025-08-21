extends Control

@export var required_points : int = 0

const item_shop_prefab = preload("res://prefabs/items/item_shop.tscn")

var current_comms: Room
var required_weapons: int = 0
var required_hats: int = 0
var required_trinkets: int = 0
var required_any: int = 0

@onready var item_grid: Grid = $ItemGrid

func _ready() -> void:
	visible = false
	SignalBus.enter_comms.connect(_on_enter_comms)

func update_everything() -> void:
	$Required/Weapons/Label.text = str(required_weapons)
	$Required/Hats/Label.text = str(required_hats)
	$Required/Trinkets/Label.text = str(required_trinkets)
	$Required/Any/Label.text = str(required_any)
	
	if required_any + required_hats + required_weapons + required_trinkets == 0:
		$Power.disabled = false
	
	if required_any == 0:
		for row in item_grid.get_children():
			for item_node : ItemShop in row.get_children():
				match(item_node.held.type):
					Item.Type.Weapon:
						if required_weapons == 0: item_node.toggle(false)
					Item.Type.Hat:
						if required_hats == 0: item_node.toggle(false)
					Item.Type.Trinket:
						if required_trinkets == 0: item_node.toggle(false)
	
func _sacrifice(item_node: ItemShop) -> void:
	match(item_node.held.type):
		Item.Type.Weapon:
			if required_weapons > 0: required_weapons -= 1
			else: required_any -= 1
		Item.Type.Hat:
			if required_hats > 0: required_hats -= 1
			else: required_any -= 1
		Item.Type.Trinket:
			if required_trinkets > 0: required_trinkets -= 1
			else: required_any -= 1
	
	CurrentRun.inventory.erase(item_node.held)
	item_node.queue_free()
	update_everything()

func _on_enter_comms(comms: Room) -> void:
	current_comms = comms
	
	$Power.visible = not comms.flag
	$Required.visible = not comms.flag
	$Power.disabled = true
	
	
	if comms.flag:
		$Message.set_string_id("comms_"+str(current_comms.heal_used))
		
		$Message.type()
	else: $Message.text = ""
	
	required_weapons = 0
	required_hats = 0
	required_trinkets = 0
	required_any = 0
	
	visible = true
	CurrentRun.state = Game.State.Window
	
	# Inventory items
	item_grid.clear()
	for item: Item in CurrentRun.inventory:
		var item_node: ItemShop = item_shop_prefab.instantiate()
		item_node.apply(item, true)
		item_node.sell.connect(_sacrifice)
		item_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		item_grid.add_to_grid(item_node)
	
	# Required
	if comms.visited:
		required_weapons = floor(comms.data / 1000)
		required_hats = floor((comms.data % 1000) / 100)
		required_trinkets = floor((comms.data % 100) / 10)
		required_any = floor(comms.data % 10)
	else:
		comms.visited = true
		var points: int = required_points
		while points > 0:
			match(randi_range(0,3)):
				0: 
					required_weapons += 1
					points -= 2
				1: 
					required_hats += 1
					points -= 2
				2: 
					required_trinkets += 1
					points -= 1
				3: 
					required_any += 1
					points -= 1
		
	update_everything()

func _on_close_pressed() -> void:
	current_comms.data = required_weapons * 1000 + required_hats * 100 + required_trinkets * 10 + required_any
	CurrentRun.state = Game.State.Map
	$Message.is_typing = false
	visible = false


func _on_power_pressed() -> void:
	current_comms.flag = true
	$Power.visible = false
	$Required.visible = false
	SignalBus.change_steps.emit(+100)
	
	
	if CurrentRun.messages_not_seen.is_empty():
		current_comms.heal_used = 9
	else:
		current_comms.heal_used = CurrentRun.messages_not_seen.pick_random()
		CurrentRun.messages_not_seen.erase(current_comms.heal_used)
	
	$Message.set_string_id("comms_"+str(current_comms.heal_used))
	$Message.type()
	
