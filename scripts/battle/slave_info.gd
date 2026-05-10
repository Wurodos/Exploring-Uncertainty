extends Control

var should_close : bool = false

func _ready() -> void:
	visible = false
	SignalBus.slave_info.connect(_on_slave_info)
	SignalBus.mouse_right_up.connect(_hide)
	SignalBus.mouse_right_down.connect(func(): 
		if CurrentRun.state == Game.State.Window and SlaveTeamNode.selected:
			_on_slave_info(SlaveTeamNode.selected.held))

func _on_slave_info(slave: Slave):
	
	should_close = false
	var i : int = 0
	for item : Item in [slave.weapon, slave.hat, slave.trinket1, slave.trinket2]:
		var entry: ItemEntry = $Entries.get_child(i)
		entry.item_name.text = item.name
		entry.item_desc.text = item.desc
		
		entry.single_target.visible = false
		entry.all_targets.visible = false
		entry.self_target.visible = false
		
		match (item.type):
			Item.Type.Weapon:
				entry.self_modulate = Color(1.0, 0.435, 0.498)
			Item.Type.Hat:
				entry.self_modulate = Color(0.459, 0.596, 1.0)
			Item.Type.Trinket:
				entry.self_modulate = Color(0.459, 1.0, 0.51)
			
		entry.visible = item.u_name != "no_trinket"
		i += 1
	
	$HPBar.value = (slave.hp/float(slave.maxhp)*100)
	$HPBar/Label.text = str(slave.hp) + "/" + str(slave.maxhp)
	
	visible = true

func _hide():
	if should_close == true: visible = false
	should_close = true
