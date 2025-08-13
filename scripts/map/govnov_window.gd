extends Control

class_name GovnovWindow

var heal_multiplier: int = 1
var value: int
var _hide_info: bool = false
var _transaction_made: bool = false

const item_shop_prefab = preload("res://prefabs/items/item_shop.tscn")

@onready var inventory_grid: Grid = $InventoryGrid

func _ready() -> void:
	$Close.text = "!"
	visible = false
	
	SignalBus.enter_govnov.connect(_on_enter_govnov)
	SignalBus.govnov_heal.connect(_on_heal)
	SignalBus.show_item_info.connect(_on_show_item_info)
	SignalBus.hide_item_info.connect(_on_hide_item_info)

func _sell(item_node: ItemShop) -> void:
	SignalBus.play_sound.emit("shop")
	
	_change_value(item_node.cost)
	CurrentRun.inventory.erase(item_node.held)
	
	
	item_node.queue_free()
	_update_items()

func _buy_slave(item_node: ItemShop) -> void:
	SignalBus.play_sound.emit("shop")
	
	$Close.text = "X"
	_transaction_made = true
	
	_change_value(-item_node.cost)
	item_node.held_slave.base_cost = 0
	
	var slave_node : SlaveTeamNode = null
	for slave: Control in $Slaves.get_children():
		if not slave.visible: 
			slave_node = slave
			break
	
	slave_node.visible = true
	slave_node.apply(item_node.held_slave, SlaveTeamNode.Type.Govnov)
	slave_node.update_healing_cost(heal_multiplier, value, 10)
	
	CurrentRun.good_boys.append(item_node.held_slave)
	
	item_node.queue_free()
	_update_items()


func _sell_slave(slave_node: SlaveTeamNode) -> void:
	SignalBus.play_sound.emit("shop")
	
	print("sold slave with hat " + slave_node.held.hat.u_name)
	_change_value(slave_node.held.get_cost())
	
	CurrentRun.good_boys.erase(slave_node.held)
	slave_node.visible = false
	_update_items()

func _change_value(new_value: int) -> void:
	value += new_value
	$Counter/Label.text = str(value)

func _update_items() -> void:
	for item_node : ItemShop in $Shop.get_children():
		if item_node.cost > value or CurrentRun.good_boys.size() == 3:
			item_node.toggle(false)
		else: item_node.toggle(true)
	
	for slave_node : SlaveTeamNode in $Slaves.get_children():
		slave_node.update_healing_cost(heal_multiplier, value, 10)


func _on_heal() -> void:
	$Close.text = "X"
	_change_value(-heal_multiplier * 10)
	_transaction_made = true
	
	heal_multiplier += 1
	for slave_node: SlaveTeamNode in $Slaves.get_children():
		slave_node.update_healing_cost(heal_multiplier, value, 10)
	
	_update_items()

func _on_enter_govnov() -> void:
	
	value = 0
	_change_value(0)
	heal_multiplier = 1
	_transaction_made = false
	
	CurrentRun.state = Game.State.Window
	visible = true
	
	var i = 0
	for slave in CurrentRun.good_boys:
		var slave_node : SlaveTeamNode = $Slaves.get_child(i)
		slave_node.visible = true
		slave_node.apply(slave, SlaveTeamNode.Type.Govnov)
		slave_node.sell.connect(func(): _sell_slave(slave_node))
		slave_node.update_healing_cost(heal_multiplier, value, 10)
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
	
	for k in range(3):
		var slave = SlavePool.fetch("blob")
	
		slave.base_maxhp += randi_range(-10, 10) 
		slave.maxhp = slave.base_maxhp
		
		slave.hp = randi_range(1, slave.maxhp)
		var item_node: ItemShop = item_shop_prefab.instantiate()
		item_node.apply_slave(slave)
		item_node.buy.connect(_buy_slave)
		$Shop.add_child(item_node)
	
	
	_update_items()
	

func _on_close_pressed() -> void:
	visible = false
	
	
	if _transaction_made:
		CurrentRun.state = Game.State.Map
	else:
		CurrentRun.arrange_difficult()
		SignalBus.battle_encounter.emit()
	
	SignalBus.end_encounter.emit()

func _on_show_item_info(item: Item) -> void:
	pass

func _on_hide_item_info() -> void:
	pass
