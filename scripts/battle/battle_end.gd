extends Control

@onready var scrap_nodes : Dictionary[Item.Scrap, Node] = {
	Item.Scrap.Flesh: $Scraps/Flesh,
	Item.Scrap.Gear: $Scraps/Gear,
	Item.Scrap.Shard: $Scraps/Shard,
	Item.Scrap.Tooth: $Scraps/Tooth,
	Item.Scrap.Oil: $Scraps/Oil
}

func _ready() -> void:
	SignalBus.show_end_battle_screen.connect(_show)

func _show(scraps: Array[Item.Scrap]):
	var scrap_dict : Dictionary[Item.Scrap, int] = {
		Item.Scrap.Flesh: 0,
		Item.Scrap.Gear: 0,
		Item.Scrap.Shard: 0,
		Item.Scrap.Tooth: 0,
		Item.Scrap.Oil: 0
	}
	
	for scrap : Item.Scrap in scraps:
		scrap_dict[scrap] += 1
	
	for scrap : Item.Scrap in scrap_nodes.keys():
		scrap_nodes[scrap].visible = scrap_dict[scrap] > 0
		scrap_nodes[scrap].get_node("Label").text = str(scrap_dict[scrap])
	
	visible = true
