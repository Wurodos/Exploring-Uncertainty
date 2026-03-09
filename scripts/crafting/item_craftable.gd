extends Control
class_name Craftable

signal crafted


@onready var req_nodes : Dictionary[Item.Scrap, Control] = {
	Item.Scrap.Flesh: %Flesh,
	Item.Scrap.Gear: %Gear,
	Item.Scrap.Shard: %Shard,
	Item.Scrap.Tooth: %Tooth,
	Item.Scrap.Oil: %Oil
}

var held: Item

func _ready() -> void:
	apply(ItemPool.fetch("alcohol"))

func apply(item: Item):
	held = item
	$ItemSprite.texture = item.texture
	if item.tier == 1:
		%Scraps.visible = true
		%Items.visible = false
		for req: Item.Scrap in [Item.Scrap.Flesh, Item.Scrap.Gear, Item.Scrap.Shard, Item.Scrap.Tooth, Item.Scrap.Oil]:
			if item.craft_reqs.has(req):
				req_nodes[req].get_node("Label").text = str(item.craft_reqs[req])
				req_nodes[req].visible = true
			else: req_nodes[req].visible = false
	else:
		%Scraps.visible = false
		%Items.visible = true
		
		for i in range(3):
			if i < item.craft_items.size():
				%Items.get_child(i).texture = item.craft_items[i].texture
			else: %Items.get_child(i).texture = null
			


func _on_craft_pressed() -> void:
	for scrap : Item.Scrap in held.craft_reqs.keys():
		CurrentRun.scraps[scrap] -= held.craft_reqs[scrap]
	var min_level := 5
	for item: Item in held.craft_items:
		var matched := CurrentRun.find_all_items(item)
		var removed_item = matched.reduce(func(it_max, it): if it.level > it_max.level: return it else: return it_max)
		CurrentRun.inventory.erase(removed_item)
		
		if removed_item.level < min_level: min_level = removed_item.level
	
	var new_item = ItemPool.fetch(held.u_name)
	for i in range(1,min_level):
		new_item.on_level_up()
	CurrentRun.put_item_in_inventory(new_item)
	crafted.emit()
