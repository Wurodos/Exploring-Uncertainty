extends Node

var picked: Pack

func _ready() -> void:
	CurrentRun.reset()
	if CurrentRun.is_saved_game:
		_end_draft()
		return
	
	SignalBus.show_item_info.connect(_on_show_item_info)
	SignalBus.hide_item_info.connect(_on_hide_item_info)
	SignalBus.pick_pack.connect(_on_pick_pack)


func _on_pick_pack(pack: Pack) -> void:
	picked = pack
	$Items.visible = true
	$PickPack.visible = false
	$PackTitle.visible = true
	$Start.visible = true
	CurrentRun.inventory.assign(pack.items.map(func(it: Item): return ItemPool.fetch(it.u_name)))
	$PackTitle.text = tr($PackTitle.string_id).format([tr("pack_" + pack.u_name + "_title")], "{}")
	
	var i := 0
	for item_node: ItemShop in $Items.get_children():
		if i < pack.items.size():
			item_node.visible = true
			item_node.apply(pack.items[i], false)
		else: item_node.visible = false
		
		i += 1


func _end_draft():
	$ItemRow.visible = false
	$Label.visible = false
	$Start.text = tr("purge")
	$Start.visible = true

func _on_start_pressed() -> void:
	picked.on_start_run()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_show_item_info(item: Item) -> void:
	$ItemEntry.apply(item)
	$ItemEntry.visible = true

func _on_hide_item_info() -> void:
	$ItemEntry.visible = false
