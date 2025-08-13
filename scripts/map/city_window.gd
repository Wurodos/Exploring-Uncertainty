extends Control

class_name CityWindow

var current_city: Room
var value: int

var _hide_info: bool = false

const item_shop_prefab = preload("res://prefabs/items/item_shop.tscn")

@onready var inventory_grid: Grid = $InventoryGrid

func _ready() -> void:
	visible = false
	
	SignalBus.enter_city.connect(_on_enter_city)
	SignalBus.city_heal.connect(_on_heal)
	SignalBus.show_item_info.connect(_on_show_item_info)
	SignalBus.hide_item_info.connect(_on_hide_item_info)



func _buy(item_node: ItemShop) -> void:
	SignalBus.play_sound.emit("shop")
	
	_change_value(-item_node.cost)
	current_city.items.erase(item_node.held)
	CurrentRun.inventory.append(item_node.held)
	
	
	item_node.apply(item_node.held, true)
	item_node.sell.connect(_sell)
	item_node.get_parent().remove_child(item_node)
	inventory_grid.add_to_grid(item_node)
	_update_items()

func _sell(item_node: ItemShop) -> void:
	SignalBus.play_sound.emit("shop")
	
	_change_value(item_node.cost)
	CurrentRun.inventory.erase(item_node.held)
	item_node.queue_free()
	_update_items()

func _change_value(new_value: int) -> void:
	value += new_value
	$Counter/Label.text = str(value)

func _update_items() -> void:
	for item_node : ItemShop in $Shop.get_children():
		if item_node.cost > value:
			item_node.toggle(false)
		else: item_node.toggle(true)
	
	for slave_node : SlaveTeamNode in $Slaves.get_children():
		if current_city.flag:
			slave_node.update_healing_cost(current_city.heal_used, value, 5)
		else:
			slave_node.update_healing_cost(current_city.heal_used, value, 10)


func _on_heal() -> void:
	
	if current_city.flag:
		_change_value(-current_city.heal_used * 5)
	else:
		_change_value(-current_city.heal_used * 10)
	
	current_city.heal_used += 1
	
	_update_items()

func _on_enter_city(city: Room) -> void:
	
	value = 0
	_change_value(0)
	
	CurrentRun.state = Game.State.Window
	visible = true
	current_city = city
	
	while $Shop.get_child_count() > 0:
		$Shop.get_child(0).free()
	
	# Inventory items
	inventory_grid.clear()
	for item: Item in CurrentRun.inventory:
		var item_node: ItemShop = item_shop_prefab.instantiate()
		item_node.apply(item, true)
		item_node.sell.connect(_sell)
		inventory_grid.add_to_grid(item_node)
	
	# Populate Items
	if not city.visited:
		city.visited = true
		for j in range(5):
			var item : Item = ItemPool.fetch_random()
			item.cost = j * 4
			city.items.append(item)
	
	if not current_city.flag and CurrentRun.discounts > 0:
		CurrentRun.discounts -= 1
		current_city.flag = true
		current_city.sprite.texture = Gallery.img_free_city
		for item in city.items: item.cost /= 2
		
	
	var j = 0
	for item in city.items:
		var item_node: ItemShop = item_shop_prefab.instantiate()
		item_node.apply(item, false)
		item_node.buy.connect(_buy)
		$Shop.add_child(item_node)
		j += 1
	
	var i = 0
	for slave in CurrentRun.good_boys:
		var slave_node : SlaveTeamNode = $Slaves.get_child(i)
		slave_node.visible = true
		slave_node.apply(slave, SlaveTeamNode.Type.City)
		i += 1
	for k in range(i,3): $Slaves.get_child(k).visible = false
	
	
	_update_items()
	

func _on_close_pressed() -> void:
	visible = false
	CurrentRun.state = Game.State.Map
	SignalBus.end_encounter.emit()

func _on_show_item_info(item: Item) -> void:
	if CurrentRun.state != Game.State.Window or item == null: return
	_hide_info = false
	$ItemEntry.visible = true
	$ItemEntry.apply(item)

func _on_hide_item_info() -> void:
	_hide_info = true
	await get_tree().create_timer(0.1).timeout
	if _hide_info: $ItemEntry.visible = false
