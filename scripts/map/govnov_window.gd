extends Control

class_name GovnovWindow

var heal_multiplier: int = 1
var value: int
var _hide_info: bool = false

const item_shop_prefab = preload("res://prefabs/items/item_shop.tscn")

@onready var inventory_grid: Grid = $InventoryGrid

func _ready() -> void:
	visible = false
	
	SignalBus.enter_govnov.connect(_on_enter_govnov)
	SignalBus.govnov_heal.connect(_on_heal)
	SignalBus.show_item_info.connect(_on_show_item_info)
	SignalBus.hide_item_info.connect(_on_hide_item_info)

func _sell(item_node: ItemShop) -> void:
	_change_value(item_node.cost)
	CurrentRun.inventory.erase(item_node.held)
	item_node.queue_free()
	_update_items()

func _buy_slave(item_node: ItemShop) -> void:
	# TODO buy slave
	
	_update_items()


func _sell_slave(slave_ndoe: SlaveTeamNode) -> void:
	# TODO sell slave
	
	_update_items()

func _change_value(new_value: int) -> void:
	value += new_value
	$Counter/Label.text = str(value)

func _update_items() -> void:
	#for item_node : ItemShop in $Shop.get_children():
	#	if item_node.cost > value:
	#		item_node.toggle(false)
	#	else: item_node.toggle(true)
	
	for slave_node : SlaveTeamNode in $Slaves.get_children():
		slave_node.update_healing_cost(heal_multiplier, value)


func _on_heal() -> void:
	
	_change_value(-heal_multiplier * 10)
	
	heal_multiplier += 1
	for slave_node: SlaveTeamNode in $Slaves.get_children():
		slave_node.update_healing_cost(heal_multiplier, value)
	
	_update_items()

func _on_enter_govnov() -> void:
	
	value = 0
	_change_value(0)
	heal_multiplier = 1
	
	CurrentRun.state = Game.State.Window
	visible = true
	
	var i = 0
	for slave in CurrentRun.good_boys:
		var slave_node : SlaveTeamNode = $Slaves.get_child(i)
		slave_node.visible = true
		slave_node.apply(slave, SlaveTeamNode.Type.City)
		slave_node.update_healing_cost(heal_multiplier, value)
		i += 1
	for j in range(i,3): $Slaves.get_child(j).visible = false
	
	while $Shop.get_child_count() > 0:
		$Shop.get_child(0).free()
	
	# Inventory items
	inventory_grid.clear()
	for item: Item in CurrentRun.inventory:
		var item_node: ItemShop = item_shop_prefab.instantiate()
		item_node.apply(item, true)
		item_node.sell.connect(_sell)
		inventory_grid.add_to_grid(item_node)
	
	# TODO generate slaves
	
	_update_items()
	

func _on_close_pressed() -> void:
	visible = false
	CurrentRun.state = Game.State.Map
	SignalBus.end_encounter.emit()

func _on_show_item_info(item: Item) -> void:
	if CurrentRun.state != Game.State.Window: return
	_hide_info = false
	$ItemEntry.visible = true
	$ItemEntry.apply(item)

func _on_hide_item_info() -> void:
	_hide_info = true
	await get_tree().create_timer(0.1).timeout
	if _hide_info: $ItemEntry.visible = false
