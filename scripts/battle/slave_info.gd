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
	if CurrentRun.is_battle_tutorial and Battle.instance.tutorial_progress == 2:
		SignalBus.advance_tutorial.emit()
	
	should_close = false
	var i : int = 0
	if slave is Enemy:
		for info : String in (slave as Enemy).info:
			var entry: ItemEntry = $Entries.get_child(i)
			entry.item_name.text = ""
			entry.item_desc.text = info
			entry.color = Color(0.532, 0.352, 0.0)
			entry.visible = true
			
			i += 1
		for j in range(i,4):
			var entry: ItemEntry = $Entries.get_child(j)
			entry.visible = false
	else:
		for item : Item in [slave.weapon, slave.hat, slave.trinket1, slave.trinket2]:
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
				
			entry.visible = item.u_name != "no_trinket"
			i += 1
	
	$HPBar.value = (slave.hp/float(slave.maxhp)*100)
	$HPBar/Label.text = str(slave.hp) + "/" + str(slave.maxhp)
	
	visible = true

func _hide():
	if should_close == true: visible = false
	should_close = true
