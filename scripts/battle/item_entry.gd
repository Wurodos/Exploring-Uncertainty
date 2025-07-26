extends ColorRect

class_name ItemEntry

@onready var item_name : Label = $Name
@onready var item_desc : Label = $Desc

@onready var single_target: Control = $Single
@onready var all_targets: Control = $All
@onready var self_target: Control = $Self

func apply(item: Item) -> void:
	item_name.text = item.name
	item_desc.text = item.desc
	
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
