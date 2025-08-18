extends ColorRect

class_name ItemEntry

const kw_box_prefab = preload("res://prefabs/items/keyword_box.tscn")

@onready var item_name : Label = $Name
@onready var item_desc : Label = $Desc

@onready var single_target: Control = $Single
@onready var all_targets: Control = $All
@onready var self_target: Control = $Self

@onready var keyword_row: BoxContainer = $KeywordRow


func apply(item: Item) -> void:
	item_name.text = item.name
	item_desc.text = item.desc
	
	$ExtraHP.visible = false
	$ExtraSpeed.visible = false
	
	single_target.visible = false
	all_targets.visible = false
	self_target.visible = false
	
	match(item.target):
		Item.Target.Single:
			single_target.visible = true
		Item.Target.AllTeam:
			all_targets.visible = true
		Item.Target.Self:
			self_target.visible = true
	
	match (item.type):
		Item.Type.Weapon:
			color = Color(1.0, 0.435, 0.498)
		Item.Type.Hat:
			color = Color(0.459, 0.596, 1.0)
		Item.Type.Trinket:
			color = Color(0.459, 1.0, 0.51)
	
	if item.extra_hp != 0:
		$ExtraHP.visible = true
		$ExtraHP/Label.text = str(item.extra_hp)
	
	if item.extra_speed != 0:
		$ExtraSpeed.visible = true
		$ExtraSpeed/Label.text = str(item.extra_speed)
	
	while keyword_row.get_child_count() > 0:
		keyword_row.get_child(0).free()
	
	for keyword : String in item.keywords:
		var kw_box = kw_box_prefab.instantiate()
		kw_box.get_node("Name").text = tr("kw_" + keyword + "_name")
		kw_box.get_node("Desc").text = tr("kw_" + keyword + "_desc")
		keyword_row.add_child(kw_box)
