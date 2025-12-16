extends TextureRect

class_name ItemEntry

const kw_box_prefab = preload("res://prefabs/items/keyword_box.tscn")

enum Type {Default, Craft}

@onready var item_name : Label = $Name
@onready var item_desc : Label = $Desc

@onready var single_target: Control = $Single
@onready var all_targets: Control = $All
@onready var self_target: Control = $Self

@onready var keyword_row: BoxContainer = $KeywordRow

@onready var req_nodes : Dictionary[Item.Scrap, Control] = {
	Item.Scrap.Flesh: $Craft/Scraps/Flesh,
	Item.Scrap.Gear: $Craft/Scraps/Gear,
	Item.Scrap.Shard: $Craft/Scraps/Shard,
	Item.Scrap.Tooth: $Craft/Scraps/Tooth,
	Item.Scrap.Oil: $Craft/Scraps/Oil
}


func apply(item: Item, type: Type = Type.Default) -> void:
	item_name.text = item.name
	item_desc.text = item.desc
	
	$ExtraHP.visible = false
	$ExtraSpeed.visible = false
	
	$LevelBorder.color = Constants.level_colors[item.level]
	
	single_target.visible = false
	all_targets.visible = false
	self_target.visible = false
	
	match (item.type):
		Item.Type.Weapon:
			self_modulate = Color(1.0, 0.435, 0.498)
		Item.Type.Hat:
			self_modulate = Color(0.459, 0.596, 1.0)
		Item.Type.Trinket:
			self_modulate = Color(0.459, 1.0, 0.51)
	
	if item.extra_hp != 0:
		$ExtraHP.visible = true
		$ExtraHP/Label.text = str(item.extra_hp)
	
	if item.extra_speed != 0:
		$ExtraSpeed.visible = true
		$ExtraSpeed/Label.text = str(item.extra_speed)
	
	$Cost.visible = true
	$Craft.visible = false
	$Cost/Label.text = str(item.cost)
	
	while keyword_row.get_child_count() > 0:
		keyword_row.get_child(0).free()
	
	for keyword : String in item.keywords:
		var kw_box = kw_box_prefab.instantiate()
		kw_box.get_node("Name").text = tr("kw_" + keyword + "_name")
		kw_box.get_node("Desc").text = tr("kw_" + keyword + "_desc")
		keyword_row.add_child(kw_box)
		
	if type == Type.Craft:
		for req: Item.Scrap in [Item.Scrap.Flesh, Item.Scrap.Gear, Item.Scrap.Shard, Item.Scrap.Tooth, Item.Scrap.Oil]:
			if item.craft_reqs.has(req):
				req_nodes[req].get_node("Label").text = str(item.craft_reqs[req])
				req_nodes[req].visible = true
			else: req_nodes[req].visible = false
		$Craft.visible = true
