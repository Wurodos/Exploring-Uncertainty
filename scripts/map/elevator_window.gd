extends Control

@export var required_points : int = 0
@onready var item_grid: Grid = $ItemGrid
@onready var teleport_row: Control = $Scroll/TeleportOptions

const item_shop_prefab = preload("res://prefabs/items/item_shop.tscn")
const teleport_prefab = preload("res://prefabs/map/teleport_option.tscn")

var current_elevator: Room
var required_weapons: int = 0
var required_hats: int = 0
var required_trinkets: int = 0
var required_any: int = 0

var id: int = 0

func _ready() -> void:
	visible = false
	SignalBus.enter_elevator.connect(_on_enter_elevator)
	SignalBus.check_elevator.connect(_check_elevator)

func _check_elevator(elevator: Room) -> void:
	if elevator.flag: return
	
	visible = true
	CurrentRun.state = Game.State.Window
	$ItemGrid.visible = false
	$Power.visible = false
	
	required_weapons = floor((elevator.data % 10000) / 1000)
	required_hats = floor((elevator.data % 1000) / 100)
	required_trinkets = floor((elevator.data % 100) / 10)
	required_any = floor(elevator.data % 10)
	
	$Required/Weapons/Label.text = str(required_weapons)
	$Required/Hats/Label.text = str(required_hats)
	$Required/Trinkets/Label.text = str(required_trinkets)
	$Required/Any/Label.text = str(required_any)
	

func update_everything() -> void:
	$Required/Weapons/Label.text = str(required_weapons)
	$Required/Hats/Label.text = str(required_hats)
	$Required/Trinkets/Label.text = str(required_trinkets)
	$Required/Any/Label.text = str(required_any)
	
	if current_elevator.flag:
		while teleport_row.get_child_count() > 0:
			teleport_row.get_child(0).free()
		for i in range(CurrentRun.elevators_repaired):
			var option : Button = teleport_prefab.instantiate()
			option.text = char(65 + i)
			if i == id: option.disabled = true
			else:
				option.pressed.connect(func(): 
					SignalBus.teleport.emit(i)
					_on_close_pressed()
				)
			teleport_row.add_child(option)
	
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

func _on_enter_elevator(elevator: Room) -> void:
	current_elevator = elevator
	$ItemGrid.visible = true
	
	$Power.visible = not elevator.flag
	$Required.visible = not elevator.flag
	$Power.disabled = true
	
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
	
	# Teleport
	teleport_row.visible = elevator.flag
	id = floor(elevator.data / 10000)
	
	# Required
	if elevator.visited:
		required_weapons = floor((elevator.data % 10000) / 1000)
		required_hats = floor((elevator.data % 1000) / 100)
		required_trinkets = floor((elevator.data % 100) / 10)
		required_any = floor(elevator.data % 10)
	else:
		elevator.visited = true
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
	current_elevator.data = 10000 * id + required_weapons * 1000 + required_hats * 100 + required_trinkets * 10 + required_any
	CurrentRun.state = Game.State.Map
	visible = false


func _on_power_pressed() -> void:
	current_elevator.flag = true
	current_elevator.sprite.texture = Gallery.img_elevator_repaired
	
	teleport_row.visible = true
	
	id = CurrentRun.elevators_repaired
	current_elevator.label.text = char(65+id)
	
	CurrentRun.elevators_repaired += 1
	current_elevator.data += 10000 * id
	
	$Power.visible = false
	$Required.visible = false
	
	update_everything()
	
