extends Control

class_name Loot

var items : Array[Item] = [] 
var scraps : Array[Item.Scrap] = []

var right_item: ItemDraggable
var left_item: ItemDraggable
var extra_item: ItemDraggable

var current_item: ItemDraggable

func _ready() -> void:
	SignalBus.show_item_info.connect(_on_show_item_info)
	SignalBus.hide_item_info.connect(_on_hide_item_info)

func start_marauder() -> void:
	items.shuffle()
	
	scraps.append_array(items.slice(items.size() / 2).map(func(item: Item): return item.get_scrap()))
	for i in range(Battle.instance.evil_team.boys_nodes.size()-1):
		scraps.append(Item.random_scrap())
	
	for scrap: Item.Scrap in scraps:
		CurrentRun.scraps[scrap] += 1
	
	items = items.slice(0, items.size() / 2)
	if items.is_empty(): 
		visible = false
		SignalBus.show_end_battle_screen.emit(scraps) 
		return
		
	right_item = $RightItem
	left_item = $LeftItem
	extra_item = $ExtraItem
	
	_present_choice()

func _present_choice() -> void:
	ItemDraggable.selected = null
	
	right_item.snap()
	left_item.snap()
	extra_item.snap()
	
	if items.size() > 1:
		right_item.apply(items.pop_back())
		left_item.apply(items.pop_back())
		extra_item.visible = false
	#elif items.size() != 1:
	#	right_item.apply(items.pop_back())
	#	left_item.apply(items.pop_back())
	#	extra_item.apply(items.pop_back())
	#	extra_item.visible = true
	else:
		right_item.apply(items.pop_back())
		left_item.visible = false
		extra_item.visible = false
			


func _on_bag_mouse_entered() -> void:
	if ItemDraggable.selected:
		CurrentRun.put_item_in_inventory(ItemDraggable.selected.held)
		if items.is_empty():
			visible = false
			SignalBus.show_end_battle_screen.emit(scraps)
		else: _present_choice()


var _hide_info = false

func _on_show_item_info(item: Item) -> void:
	_hide_info = false
	$ItemInfo.visible = true
	$ItemInfo.apply(item)

func _on_hide_item_info() -> void:
	_hide_info = true
	await get_tree().create_timer(0.1).timeout
	if _hide_info: $ItemInfo.visible = false
		
