extends Control

const item_craftable = preload("res://prefabs/items/item_craftable.tscn")

@onready var scrap_nodes : Dictionary[Item.Scrap, Node] = {
	Item.Scrap.Flesh: $Scraps/Flesh,
	Item.Scrap.Gear: $Scraps/Gear,
	Item.Scrap.Shard: $Scraps/Shard,
	Item.Scrap.Tooth: $Scraps/Tooth,
	Item.Scrap.Oil: $Scraps/Oil
}

@onready var craftable_container : Control = $ScrollContainer/Craftables


func _ready() -> void:
	visible = false
	$DebugAddOne.visible = CurrentRun.is_debug

func _on_show_craft_pressed() -> void:
	visible = true
	CurrentRun.state = Game.State.Window
	
	while craftable_container.get_child_count() > 0:
		craftable_container.get_child(0).free()
	
	for recipe : Item in CurrentRun.craft_recipes:
		var craftable: Craftable = item_craftable.instantiate()
		craftable_container.add_child(craftable)
		craftable.apply(recipe)
	
	_update()

func _update() -> void:
	for scrap : Item.Scrap in scrap_nodes.keys():
		scrap_nodes[scrap].get_node("Label").text = str(CurrentRun.scraps[scrap])
	
	for craftable: Craftable in craftable_container.get_children():
		if not craftable.crafted.is_connected(_update):
			craftable.crafted.connect(_update)
		var enough_scraps := true
		for scrap : Item.Scrap in craftable.held.craft_reqs.keys():
			if CurrentRun.scraps[scrap] < craftable.held.craft_reqs[scrap]:
				craftable.get_node("Craft").disabled = true
				enough_scraps = false
		if not enough_scraps: continue
		
		var needed: Array[Item] = craftable.held.craft_items.duplicate()
		for item : Item in CurrentRun.inventory:
			var id = needed.find_custom(func(it): return it.u_name == item.u_name)
			if id != -1:
				needed.pop_at(id)
		if not needed.is_empty():
			craftable.get_node("Craft").disabled = true
		else:
			craftable.get_node("Craft").disabled = false


func _on_close_pressed() -> void:
	visible = false
	CurrentRun.state = Game.State.Map


func _on_debug_add_one_pressed() -> void:
	for key in CurrentRun.scraps:
		CurrentRun.scraps[key] += 1
	_update()
