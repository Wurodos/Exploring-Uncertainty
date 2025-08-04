extends Node

var deck : Array[Item] = []

func _ready() -> void:
	for i in range(3):
		deck.append(ItemPool.fetch_random(Item.Type.Weapon))
		deck.append(ItemPool.fetch_random(Item.Type.Hat))
		
		$ItemRow.get_child(i).buy.connect(_buy)
	for i in range(6):
		deck.append(ItemPool.fetch_random(Item.Type.Trinket))
	
	SignalBus.show_item_info.connect(_on_show_item_info)
	SignalBus.hide_item_info.connect(_on_hide_item_info)
	deck.shuffle()
	_next()

func _next() -> void:
	if deck.is_empty():
		$ItemRow.visible = false
		$Label.visible = false
		$Start.visible = true
		return
	
	for i in range(3):
		var item : Item = deck.pop_back()
		var item_node : ItemShop = $ItemRow.get_child(i)
		item_node.apply(item, false)
		

func _buy(item_node: ItemShop) -> void:
	CurrentRun.inventory.append(item_node.held)
	$ItemEntry.visible = false
	_next()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_show_item_info(item: Item) -> void:
	$ItemEntry.apply(item)
	$ItemEntry.visible = true

func _on_hide_item_info() -> void:
	$ItemEntry.visible = false
