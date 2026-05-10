extends Control

const map_scene = preload("res://scenes/map.tscn")
const battle_scene = preload("res://scenes/battle.tscn")

@export var slave_item_animation: AnimationPlayer
@export var slave_opacity: AnimationPlayer
@export var slave_detached: Control
@export var slave_pos_scale: Control
@export var text_node: RichLocalized
@export var timer: Timer

var battle_node: Battle
var map_node: Map

var current: int = 0
var expect_items: Array[String] = []
var allow_continue_from_click: bool = true

func _ready() -> void:
	CurrentRun.reset()
	
	for item: Item in ItemPool._pool.values():
		if item.is_item():
			CurrentRun.craft_pool.append(item.duplicate())
	
	text_node.set_string_id("tutorial_new_0")
	SignalBus.mouse_up.connect(_on_gui_input)
	SignalBus.end_battle.connect(back_to_map)
	SignalBus.exit_the_mines.connect(finish_tutorial)
	
	(func():
		CurrentRun.good_boys[0].item_equipped.connect(on_equip)
		CurrentRun.inventory = [ItemPool.fetch("heart_lock"), ItemPool.fetch("sword"), ItemPool.fetch("bomb"), ItemPool.fetch("chef")]
		SignalBus.refresh.emit()
	).call_deferred()

func finish_tutorial() -> void:
	CurrentRun.is_tutorial = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_gui_input() -> void:
	if not allow_continue_from_click: return
	continue_tutorial()

func back_to_map() -> void:
	battle_node.queue_free()
	
	map_node.visible = true
	map_node.camera.make_current()
	SignalBus.focus_camera.emit(map_node.room_at(map_node.party_row, map_node.party_col).global_position)
	map_node.get_node("GUI").visible = true
	CurrentRun.state = Game.State.Map
	

func toggle_input(active: bool):
	allow_continue_from_click = active
		

func continue_tutorial() -> void:
	current += 1
	text_node.set_string_id("tutorial_new_"+str(current))
	toggle_input(false)
	$SkipCooldown.start()
	match(current):
		2: slave_item_animation.play("appear")
		3: detach_slave()
		4: start_brigade_tutorial()
		7: start_equip_tutorial(["sword"])
		11: start_equip_tutorial(["chef"])
		13: 
			start_equip_tutorial(["bomb", "heart_lock"])
		15: 
			start_map_tutorial()
			map_node.move_enabled = false
		16: wait_for_move()
		17: map_node.move_enabled = false
		18: wait_for_move()
		19: battle(0)
		20: right_click()
		22: 
			Battle.instance.allow_sender = 0
			Battle.instance.allow_victim = 0
			wait_for_win()
		23: wait_for_map()
		24: wait_for_brigade()
		26: start_equip_tutorial(["bomb"])
		27: wait_for_move()
		28: battle(1)
		33: 
			toggle_input(false)
			timer.stop()
			Battle.instance.allow_sender = 2
			Battle.instance.allow_ally = 0
			wait_for_turn()
		34:
			toggle_input(false)
			timer.stop()
			Battle.instance.allow_sender = 0
			Battle.instance.allow_ally = 0
			wait_for_turn()
		35:
			toggle_input(false)
			timer.stop()
			Battle.instance.allow_sender = 1
			Battle.instance.allow_ally = -1
			Battle.instance.allow_victim = 0
			wait_for_turn()
		36:
			toggle_input(false)
			timer.stop()
			Battle.instance.allow_sender = 0
			Battle.instance.allow_victim = 0
			wait_for_turn()
		37:
			CurrentRun.is_tutorial = false
			wait_for_map()
		38:
			CurrentRun.is_tutorial = true
		40:
			toggle_input(false)
			timer.stop()
		
func wait_for_brigade() -> void:
	toggle_input(false)
	timer.stop()
	CurrentRun.good_boys.append_array([SlavePool.fetch("blob"), SlavePool.fetch("blob")])
	SignalBus.refresh.emit()
	map_node.move_enabled = false
	SignalBus.open_team_window.connect(func(): continue_tutorial(), CONNECT_ONE_SHOT)

func wait_for_map() -> void:
	toggle_input(false)
	timer.stop()
	SignalBus.end_battle.connect(func(): continue_tutorial(), CONNECT_ONE_SHOT)

func wait_for_win() -> void:
	toggle_input(false)
	timer.stop()
	SignalBus.good_won.connect(func(): continue_tutorial(), CONNECT_ONE_SHOT)

func wait_for_turn() -> void:
	toggle_input(false)
	timer.stop()
	SignalBus.did_action.connect(func(): continue_tutorial(), CONNECT_ONE_SHOT)

func right_click() -> void:
	toggle_input(false)
	timer.stop()
	SignalBus.enemy_info.connect(func(_slave): continue_tutorial(), CONNECT_ONE_SHOT)

func battle(num: int) -> void:
	if num == 0:
		seed(10)
		var enemy = SlavePool.fetch("cherv")
		enemy.equip(ItemPool.fetch("anvil"))
		enemy.equip(ItemPool.fetch("razor"))
		CurrentRun.evil_boys = [enemy]
	elif num == 1:
		seed(15)
		var enemy = SlavePool.fetch("cherv")
		enemy.equip(ItemPool.fetch("helmet"))
		enemy.equip(ItemPool.fetch("turbine"))
		CurrentRun.evil_boys = [enemy]
		
	
	SignalBus.battle_encounter.emit()
	battle_node = battle_scene.instantiate()
	add_child(battle_node)
	battle_node.wave_count = 1
	$Camera2D.enabled = true
	$Camera2D.make_current()

func detach_slave() -> void:
	slave_item_animation.play_backwards("appear")
	slave_detached.reparent(slave_detached.get_parent().get_parent())
	var tween = get_tree().create_tween()
	slave_opacity.play("opacity")
	tween.tween_property(slave_detached, "position", slave_pos_scale.position, 0.5)
	tween.parallel().tween_property(slave_detached, "scale", slave_pos_scale.scale, 0.5)

func start_brigade_tutorial() -> void:
	%ShowTeam.visible = true
	%LeftClick.visible = false
	timer.stop()

func start_equip_tutorial(item_names: Array[String]) -> void:
	expect_items.clear()
	for item_name in item_names:
		if CurrentRun.good_boys[0].get_all_items().find_custom(func(it): return it.u_name == item_name) > -1:
			continue_tutorial()
			continue
		
		timer.stop()
		expect_items.append(item_name)

func wait_for_move() -> void:
	map_node.move_enabled = true
	toggle_input(false)
	timer.stop()
	SignalBus.entered_room.connect(on_entered_room)

func on_entered_room(room: Room):
	if room.type == Room.Type.Empty:
		SignalBus.entered_room.disconnect(on_entered_room)
		continue_tutorial()
		

func start_map_tutorial() -> void:
	mock_map()
	%Introduction.visible = false
	%SlaveItemShowcase.visible = false
	%ShowTeam.visible = false
	%TeamWindow.queue_free()

func mock_map() -> void:
	map_node = map_scene.instantiate()
	$MockMap.add_child(map_node)
	
	map_node.generate_empty()	
	map_node._on_debug_stop_fight_toggled(true)
	
	for i in range(1,5):
		map_node.add_room(map_node.party_row, map_node.party_col+i)
	map_node.add_room(map_node.party_row, map_node.party_col+5, Room.Type.City)
	map_node.add_room(map_node.party_row, map_node.party_col+6)
	map_node.add_room(map_node.party_row, map_node.party_col+7, Room.Type.Exit)
	
	map_node._update_move_buttons()

func on_equip(item: Item) -> void:
	if expect_items.has(item.u_name):
		expect_items.erase(item.u_name)
		if expect_items.is_empty():
			continue_tutorial()

func _on_skip_cooldown_timeout() -> void:
	toggle_input(true)


func _on_show_team_pressed() -> void:
	if current == 4:
		continue_tutorial()
