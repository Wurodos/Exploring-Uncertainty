extends Control

func _ready() -> void:
	SignalBus.slave_info.connect(_on_slave_info)
	SignalBus.mouse_right_up.connect(_hide)

func _on_slave_info(slave_node: SlaveNode):
	var i : int = 0
	if slave_node.held is Enemy:
		for info : String in slave_node.held.get_all_info():
			var entry: ItemEntry = $Entries.get_child(i)
			entry.item_name.text = ""
			entry.item_desc.text = info
			entry.color = Color(1.0, 0.761, 0.42)
			entry.visible = info != ""
			
			i += 1
	else:
		for item : Item in slave_node.get_all_items():
			var entry: ItemEntry = $Entries.get_child(i)
			entry.item_name.text = item.name
			entry.item_desc.text = item.desc
			
			entry.single_target.visible = false
			entry.all_targets.visible = false
			entry.self_target.visible = false
			
			if item.type != Item.Type.Trinket:
				match (item.target):
					Item.Target.Single:
						entry.single_target.visible = true
					Item.Target.AllTeam:
						entry.all_targets.visible = true
					Item.Target.Self:
						entry.self_target.visible = true
			
			match (item.type):
				Item.Type.Weapon:
					entry.color = Color(1.0, 0.435, 0.498)
				Item.Type.Hat:
					entry.color = Color(0.459, 0.596, 1.0)
				Item.Type.Trinket:
					entry.color = Color(0.459, 1.0, 0.51)
				
			entry.visible = item.name != ""
			i += 1
	
	$HPBar.value = (slave_node.held.hp/float(slave_node.held.maxhp)*100)
	$HPBar/Label.text = str(slave_node.held.hp) + "/" + str(slave_node.held.maxhp)
	
	visible = true

func _hide():
	visible = false
