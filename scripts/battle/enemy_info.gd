extends Control

@export var enemy_image: TextureRect = null

var should_close : bool = false

func _ready() -> void:
	visible = false
	SignalBus.enemy_info.connect(_on_slave_info)
	SignalBus.mouse_right_up.connect(_hide)
	SignalBus.mouse_right_down.connect(func(): 
		if CurrentRun.state == Game.State.Window and SlaveTeamNode.selected:
			_on_slave_info(SlaveTeamNode.selected.held))

func _on_slave_info(slave: Enemy):
	should_close = false
	$Name.text = tr(slave.u_name)
	enemy_image.texture = slave.texture
	
	for entry in $Entries.get_children(): entry.visible = false 
	for entry in $Quirks.get_children(): entry.visible = false 
	
	var i : int = 0
	for item : Item in slave.get_all_items():
		var entry: ItemEntry = $Entries.get_child(i)
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
		i += 1
	
	i = 0
	for quirk: Quirk in slave.quirks:
		var entry: ItemEntry = $Quirks.get_child(i)
		entry.visible = true
		entry.item_name.text = tr("quirk_"+quirk.id+"_title")
		entry.item_desc.text = tr("quirk_"+quirk.id+"_desc")
		i += 1
	$TimerBar.visible = slave.intention.timer > 0
	$TimerBar.max_value = slave.intention.timer_damage_max
	$TimerBar.value = slave.intention.timer_damage_remain
	$TimerBar/Label.text = str(slave.intention.timer_damage_remain) + "/" + str(slave.intention.timer_damage_max)
	$HPBar.value = (slave.hp/float(slave.maxhp)*100)
	$HPBar/Label.text = str(slave.hp) + "/" + str(slave.maxhp)
	
	visible = true

func _hide():
	if should_close == true: visible = false
	should_close = true
