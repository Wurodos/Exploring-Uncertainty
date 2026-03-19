extends Control

var should_close : bool = false

func _ready() -> void:
	visible = false
	SignalBus.enemy_info.connect(_on_slave_info)
	SignalBus.mouse_right_up.connect(_hide)
	SignalBus.mouse_right_down.connect(func(): 
		if CurrentRun.state == Game.State.Window and SlaveTeamNode.selected:
			_on_slave_info(SlaveTeamNode.selected.held))

func _on_slave_info(slave: Enemy):
	if CurrentRun.is_battle_tutorial and Battle.instance.tutorial_progress == 2:
		SignalBus.advance_tutorial.emit()
	
	should_close = false
	for entry in $Entries.get_children(): entry.visible = false 
	for i in range(slave.info_count):
		var entry: ItemEntry = $Entries.get_child(i)
		entry.visible = true
		entry.item_name.text = slave.info_title[i]
		entry.item_desc.text = slave.info[i]
		entry.self_modulate = Color.WHITE
	
	var i = slave.info_count
	var actual_entries = slave.info_count
	for item : Item in slave.get_all_items():
		var entry: ItemEntry = $Entries.get_child(i)
		if not entry: continue
		entry.item_name.text = item.name
		entry.item_desc.text = item.desc
		
		match (item.type):
			Item.Type.Weapon:
				entry.self_modulate = Color(1.0, 0.435, 0.498)
			Item.Type.Hat:
				entry.self_modulate = Color(0.459, 0.596, 1.0)
			Item.Type.Trinket:
				entry.self_modulate = Color(0.459, 1.0, 0.51)
			
		entry.visible = item.is_item()
		if item.is_item(): actual_entries += 1
		i += 1
	
	$HPBar.value = (slave.hp/float(slave.maxhp)*100)
	$HPBar/Label.text = str(slave.hp) + "/" + str(slave.maxhp)
	
	if actual_entries > 4: $Entries.scale = Vector2(0.6,0.6) 
	else: $Entries.scale = Vector2(1,1)
	
	visible = true

func _hide():
	if should_close == true: visible = false
	should_close = true
