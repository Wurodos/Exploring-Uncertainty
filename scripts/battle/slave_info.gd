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
			
			entry.visible = info != ""
			
			i += 1
	else:
		for item : Item in slave_node.get_all_items():
			var entry: ItemEntry = $Entries.get_child(i)
			entry.item_name.text = item.name
			entry.item_desc.text = item.desc
			entry.visible = item.name != ""
			i += 1
	
	$HPBar.value = (slave_node.held.hp/float(slave_node.held.maxhp)*100)
	$HPBar/Label.text = str(slave_node.held.hp) + "/" + str(slave_node.held.maxhp)
	
	visible = true

func _hide():
	visible = false
