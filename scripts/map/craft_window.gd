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
		for scrap : Item.Scrap in craftable.held.craft_reqs.keys():
			if CurrentRun.scraps[scrap] < craftable.held.craft_reqs[scrap]:
				craftable.get_node("Craft").disabled = true
				break


func _on_close_pressed() -> void:
	visible = false
	CurrentRun.state = Game.State.Map
