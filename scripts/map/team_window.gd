extends Control

@onready var item_grid: Grid = $ItemGrid

const item_draggable_prefab = preload("res://prefabs/items/item_draggable.tscn")

var _hide_info : bool = false

func _ready() -> void:
	visible = false
	
	SignalBus.add_item.connect(_on_add_item)
	SignalBus.show_item_info.connect(_on_show_item_info)
	SignalBus.hide_item_info.connect(_on_hide_item_info)
	SignalBus.mouse_up.connect(_on_mouse_up)
	SignalBus.end_battle.connect(_on_battle_end)
	SignalBus.end_encounter.connect(_refresh_slaves)
	
	
	for child : Control in $Slaves.get_children():
		child.visible = false
	
	var i = 0
	for slave in CurrentRun.good_boys:
		var slave_node : SlaveTeamNode = $Slaves.get_child(i)
		slave_node.visible = true
		slave_node.apply(slave, SlaveTeamNode.Type.Brigade)
		i += 1

func refresh_inventory() -> void:
	item_grid.clear()
	for item : Item in CurrentRun.inventory:
		var item_draggable : ItemDraggable = item_draggable_prefab.instantiate()
		item_draggable.apply(item)
		item_grid.add_to_grid(item_draggable)

func _refresh_slaves() -> void:
	for child : Control in $Slaves.get_children():
		child.visible = false
	
	var i = 0
	for slave in CurrentRun.good_boys:
		var slave_node : SlaveTeamNode = $Slaves.get_child(i)
		slave_node.visible = true
		slave_node.apply(slave, SlaveTeamNode.Type.Brigade)
		i += 1

func _on_battle_end() -> void:
	_refresh_slaves()

func _on_mouse_up() -> void:
	var item_node : ItemDraggable = ItemDraggable.selected
	var slave_node : SlaveTeamNode = SlaveTeamNode.selected
	
	if item_node and slave_node:
		var trinket_id = 1
		if item_node.held.type == Item.Type.Trinket \
			and slave_node.held.trinket1.is_item():
				trinket_id = 2
		
		# Don't allow equipping an item if it leads to <= 0 HP!
		
		if slave_node.held.hp - slave_node.held.get_item(item_node.held.type).extra_hp\
			+ item_node.held.extra_hp <= 0: return
		
		var old_item : Item = slave_node.held.equip(item_node.held, trinket_id)
		if old_item.is_item():
			CurrentRun.inventory.append(old_item)
			SignalBus.add_item.emit(old_item)
		
		slave_node.apply(slave_node.held, SlaveTeamNode.Type.Brigade)
		
		CurrentRun.inventory.erase(item_node.held)
		item_node.queue_free()
		
func _on_add_item(item: Item) -> void:
	
	
	var item_draggable : ItemDraggable = item_draggable_prefab.instantiate()
	item_draggable.apply(item)
	item_grid.add_to_grid(item_draggable)

func _on_show_item_info(item: Item) -> void:
	if CurrentRun.state != Game.State.Map: return
	_hide_info = false
	$ItemEntry.visible = true
	$ItemEntry.apply(item)

func _on_hide_item_info() -> void:
	_hide_info = true
	await get_tree().create_timer(0.1).timeout
	if _hide_info: $ItemEntry.visible = false

func _on_show_team_pressed() -> void:
	refresh_inventory()
	visible = true

func _on_close_pressed() -> void:
	visible = false
