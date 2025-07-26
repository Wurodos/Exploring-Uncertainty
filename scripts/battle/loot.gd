extends Control

class_name Loot

var items : Array[Item] = [] 

var right_item: ItemDraggable
var left_item: ItemDraggable
var extra_item: ItemDraggable

var current_item: ItemDraggable

func _ready() -> void:
	SignalBus.show_item_info.connect(_on_show_item_info)
	SignalBus.hide_item_info.connect(_on_hide_item_info)

func start_marauder() -> void:
	if items.is_empty(): 
		SignalBus.end_battle.emit() 
		return
		
	right_item = $RightItem
	left_item = $LeftItem
	extra_item = $ExtraItem
	items.shuffle()
	_present_choice()

func _present_choice() -> void:
	ItemDraggable.selected = null
	
	right_item.snap()
	left_item.snap()
	extra_item.snap()
	
	if items.size() % 2 == 0:
		right_item.apply(items.pop_back())
		left_item.apply(items.pop_back())
		extra_item.visible = false
	elif items.size() != 1:
		right_item.apply(items.pop_back())
		left_item.apply(items.pop_back())
		extra_item.apply(items.pop_back())
		extra_item.visible = true
	else:
		right_item.apply(items.pop_back())
		left_item.visible = false
		extra_item.visible = false
			


func _on_bag_mouse_entered() -> void:
	if ItemDraggable.selected:
		CurrentRun.inventory.append(ItemDraggable.selected.held)
		if items.is_empty():
			visible = false
			SignalBus.end_battle.emit()
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
		
