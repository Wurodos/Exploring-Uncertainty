extends Control
class_name Craftable

signal crafted


@onready var req_nodes : Dictionary[Item.Scrap, Control] = {
	Item.Scrap.Flesh: $ItemSprite/Flesh,
	Item.Scrap.Gear: $ItemSprite/Gear,
	Item.Scrap.Shard: $ItemSprite/Shard,
	Item.Scrap.Tooth: $ItemSprite/Tooth,
	Item.Scrap.Oil: $ItemSprite/Oil
}

var held: Item

func _ready() -> void:
	apply(ItemPool.fetch("alcohol"))

func apply(item: Item):
	held = item
	$ItemSprite.texture = item.texture
	for req: Item.Scrap in [Item.Scrap.Flesh, Item.Scrap.Gear, Item.Scrap.Shard, Item.Scrap.Tooth, Item.Scrap.Oil]:
		if item.craft_reqs.has(req):
			req_nodes[req].get_node("Label").text = str(item.craft_reqs[req])
			req_nodes[req].visible = true
		else: req_nodes[req].visible = false
	


func _on_craft_pressed() -> void:
	for scrap : Item.Scrap in held.craft_reqs.keys():
		CurrentRun.scraps[scrap] -= held.craft_reqs[scrap]
	CurrentRun.put_item_in_inventory(ItemPool.fetch(held.u_name))
	crafted.emit()
