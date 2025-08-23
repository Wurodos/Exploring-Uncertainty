extends Node2D

class_name Battle

static var instance: Battle

@onready var good_team: Team = $World/GoodTeam
@onready var evil_team: Team = $World/EvilTeam
@onready var queue_node: Control = $UI/SpeedQueue
@onready var line2d : Line2D = $World/Line2D
@onready var loot_node: Loot = $UI/Loot
@onready var tutorial_box: Control = $UI/TutorialBox

const queue_element = preload("res://prefabs/battle/queue_element.tscn")

var speed_queue: Array[Slave] = []
var current_slave_position : int = 0
var current_slave: Slave
var current_slave_node: SlaveNode

var selected_sender: SlaveNode
var selected_victim: SlaveNode

var is_line : bool = false
var is_marauder : bool = false

var tutorial_progress: int = 0

func _ready() -> void:
	instance = self

	tutorial_box.visible = CurrentRun.is_battle_tutorial
	tutorial_box.get_node("Text").set_string_id("tutorial_battle_0")
	
	if CurrentRun.is_battle_tutorial:
		SignalBus.advance_tutorial.connect(_on_tutorial_ok_pressed)
	
	SignalBus.start_battle.connect(_on_start_battle)
	SignalBus.new_round.connect(_on_new_round)
	SignalBus.new_turn.connect(_on_new_turn)
	SignalBus.mouse_dragged.connect(_on_mouse_dragged)
	SignalBus.mouse_up.connect(_on_mouse_released)
	
	SignalBus.speed_queue_mouse_entered.connect(_on_speed_queue_mouse_entered)
	SignalBus.speed_queue_mouse_exit.connect(_on_speed_queue_mouse_exited)
	
	SignalBus.slave_selected.connect(_on_slave_selected)
	SignalBus.slave_mouse_entered.connect(_on_slave_mouse_entered)
	SignalBus.slave_mouse_exited.connect(_on_slave_mouse_exited)
	SignalBus.slave_death.connect(_on_slave_death)
	SignalBus.slave_ran.connect(func(slave): _on_slave_death(slave, false))
	
	SignalBus.evil_won.connect(_on_evil_won)
	SignalBus.good_won.connect(_on_good_won)
	
	SignalBus.start_battle.emit()

func recalculate_speed():
	var current_slave = speed_queue[current_slave_position]
	queue_node.get_child(current_slave_position).toggle_select(false)
	
	speed_queue = []
	while queue_node.get_child_count() > 0:
		queue_node.get_child(0).free()
	
	speed_queue.append_array(CurrentRun.good_boys)
	speed_queue.append_array(CurrentRun.evil_boys)
	
	speed_queue = speed_queue.filter\
		(func(boy: Slave): return boy.is_alive)	
	
	speed_queue.sort_custom(_compare_speeds)
	
	for slave : Slave in speed_queue:
		var new_element : QueueElement = queue_element.instantiate()
		new_element.apply(slave)
		queue_node.add_child(new_element)
	
	current_slave_position = speed_queue.find(current_slave)
	queue_node.get_child(current_slave_position).toggle_select(true)

func _on_start_battle():
	for slave: SlaveNode in evil_team.boys_nodes:
		slave.start_battle()
	for slave: SlaveNode in good_team.boys_nodes:
		slave.start_battle()
	
	SignalBus.new_round.emit()
	current_slave_position = -1
	SignalBus.new_turn.emit()

# Create speed queueasass
func _on_new_round():
	current_slave_position = 0
	speed_queue = []
	while queue_node.get_child_count() > 0:
		queue_node.get_child(0).free()
	
	speed_queue.append_array(CurrentRun.good_boys)
	speed_queue.append_array(CurrentRun.evil_boys)
	
	speed_queue = speed_queue.filter\
		(func(boy: Slave): return boy.is_alive)	
	
	speed_queue.sort_custom(_compare_speeds)
	
	# Randomize slaves that have the same speed
	# in other words, speed brackets
	
	var bracket : Array[Slave] = []
	var br_start : int = 0
	for i in range(speed_queue.size()):
		if speed_queue[i].speed != \
				speed_queue[br_start].speed:
			bracket.shuffle()
			for j in range(bracket.size()):
				speed_queue[br_start + j] = bracket[j]
			br_start = i
			bracket.clear()
		bracket.append(speed_queue[i])
	
	bracket.shuffle()
	for j in range(bracket.size()):
		speed_queue[br_start + j] = bracket[j]
	
	
	
	for slave : Slave in speed_queue:
		var new_element : QueueElement = queue_element.instantiate()
		new_element.apply(slave)
		queue_node.add_child(new_element)

func _compare_speeds(slave_1: Slave, slave_2: Slave) -> bool:
	return slave_1.speed > slave_2.speed

func _on_new_turn() -> void:
	if current_slave_position >= 0:
		queue_node.get_child(current_slave_position).toggle_select(false)
	
	current_slave_position += 1
	
	if current_slave_position >= queue_node.get_child_count():
		for slave : SlaveNode in good_team.boys_nodes:
			slave.ticker_down_buffs()
		for slave : SlaveNode in evil_team.boys_nodes:
			slave.ticker_down_buffs()
		SignalBus.new_round.emit()
	
	queue_node.get_child(current_slave_position).toggle_select(true)
	current_slave = speed_queue[current_slave_position]
	current_slave_node = _find_slave_node(current_slave)
	
	for slave_node in good_team.boys_nodes:
		if slave_node.held == current_slave:
			slave_node.start_turn()
			break
	
	if current_slave is Enemy:
		for slave_node in evil_team.boys_nodes:
			if slave_node.held == current_slave:
				slave_node.execute_intention()
				break

func _on_slave_death(slave_node: SlaveNode, is_loot: bool = true) -> void:
	if slave_node.held is Enemy:
		var dude : Enemy = slave_node.held
		if dude.is_final_boss:
			$AnimationPlayer.play("win")
			SignalBus.new_turn.disconnect(_on_new_turn)
			return
	
	if is_loot:
		for item : Item in slave_node.get_all_items():
			if item.is_item():
				loot_node.items.append(item)
	
	for i in range(speed_queue.size()):
		if speed_queue[i] == slave_node.held:
			queue_node.get_child(i).free()
			speed_queue.remove_at(i)
			
			if i < current_slave_position:
				current_slave_position -= 1
			elif i == current_slave_position:
				slave_node.toggle_arrow(false)
				current_slave_position -= 1
				
				# dirty hack, can cause issues later
				get_tree().create_timer(1).timeout.connect(func(): SignalBus.new_turn.emit())
			break
	
	if good_team.boys.is_empty():
		SignalBus.evil_won.emit()
	elif evil_team.boys.is_empty():
		SignalBus.good_won.emit()
	
	if current_slave_position == speed_queue.size():
		SignalBus.new_round.emit()			

func _on_slave_selected(slave_node: SlaveNode) -> void:
	if is_marauder: return
	if slave_node.held == current_slave and not slave_node.team.is_evil:
		slave_node.toggle_ellipse(true)
		selected_sender = slave_node
		is_line = true
		line2d.self_modulate = Color.WHITE
		slave_node.ellipse.self_modulate = Color.WHITE

func _on_mouse_dragged(pos: Vector2):
	if is_line:
		if selected_victim:
			line2d.points = [selected_sender.line_start, selected_victim.line_end]
		else:
			line2d.points = [selected_sender.line_start, pos]
	
func _on_mouse_released():
	is_line = false
	line2d.points = []
	if selected_victim:
		if selected_victim.team.is_evil:
			if CurrentRun.is_battle_tutorial and tutorial_progress == 4:
				SignalBus.advance_tutorial.emit()
			selected_sender.attack(selected_victim)
		else:
			if CurrentRun.is_battle_tutorial and tutorial_progress == 6:
				SignalBus.advance_tutorial.emit()
			selected_sender.support(selected_victim)
		selected_victim = null
		SignalBus.new_turn.emit()

func _on_slave_mouse_entered(slave_node: SlaveNode):
	if is_line:
		if not slave_node.team.is_evil and slave_node != selected_sender and selected_sender.held.hat.target == Item.Target.Self:
			return
		if CurrentRun.is_battle_tutorial and tutorial_progress == 4 and not slave_node.team.is_evil:
			return
		if CurrentRun.is_battle_tutorial and tutorial_progress == 6 and slave_node.team.is_evil:
			return
		
		
		selected_victim = slave_node
		selected_victim.toggle_ellipse(true)
		if selected_victim.team.is_evil:
			line2d.self_modulate = Color.RED
			selected_sender.ellipse.self_modulate = Color.RED
			selected_victim.ellipse.self_modulate = Color.RED
		elif selected_victim != selected_sender: 
			line2d.self_modulate = Color.DEEP_SKY_BLUE
			selected_sender.ellipse.self_modulate = Color.DEEP_SKY_BLUE
			selected_victim.ellipse.self_modulate = Color.DEEP_SKY_BLUE
		else:
			line2d.self_modulate = Color.TRANSPARENT
			selected_sender.ellipse.self_modulate = Color.GREEN_YELLOW

func _on_slave_mouse_exited(slave_node: SlaveNode):
	if selected_victim:
		line2d.self_modulate = Color.WHITE
		selected_sender.ellipse.self_modulate = Color.WHITE
		selected_victim.ellipse.self_modulate = Color.WHITE
		if selected_sender != selected_victim:
			selected_victim.toggle_ellipse(false)
		selected_victim = null

func _on_speed_queue_mouse_entered(slave: Slave):
	if slave == current_slave: return
	
	var slave_node = _find_slave_node(slave)
	current_slave_node.arrow.visible = false
	slave_node.arrow.visible = true
	slave_node.arrow_animation.play("bounce")

func _on_speed_queue_mouse_exited(slave: Slave):
	if slave == current_slave: return
	var slave_node = _find_slave_node(slave)
	
	if not current_slave_node.team.is_evil:
		current_slave_node.arrow.visible = true
		
	slave_node.arrow.visible = false
	slave_node.arrow_animation.play("RESET")

func _on_good_won() -> void:
	print("Good won!")
	is_marauder = true
	CurrentRun.good_boys = CurrentRun.good_boys.filter(func(slave: Slave): return slave.is_alive)
	SignalBus.stop_music.emit()
	
	for slave : Slave in CurrentRun.good_boys:
		slave.speed = slave.base_speed
	
	loot_node.start_marauder()
	loot_node.visible = true
	
	if CurrentRun.is_battle_tutorial:
		tutorial_progress = 0
		tutorial_box.visible = true
		tutorial_box.get_node("Text").set_string_id("tutorial_battle_loot_0")
	
	
	
	## DEBUG -> Inventory limit
	#for i in range(8): CurrentRun.put_item_in_inventory(ItemPool.fetch("bomb"))
	

func _on_evil_won() -> void:
	print("Evil won!")
	SignalBus.new_turn.disconnect(_on_new_turn)
	$AnimationPlayer.play("fail")

func _find_slave_node(slave: Slave) -> SlaveNode:
	var slave_node: SlaveNode = null
	var id = good_team.boys_nodes.find_custom(func(node): return node.held == slave)
	
	if id != -1: 
		slave_node = good_team.boys_nodes[id]
	else:
		id = evil_team.boys_nodes.find_custom(func(node): return node.held == slave)
		slave_node = evil_team.boys_nodes[id]
	return slave_node

# ====================
# Debug panel
# ====================

func _on_newturn_pressed() -> void:
	SignalBus.new_turn.emit()


func _on_lower_hp_pressed() -> void:
	evil_team.boys_nodes[1].set_hp(1, false)
	evil_team.boys_nodes[2].set_hp(1, false)


func _on_restart_pressed() -> void:
	get_tree().quit()


func _on_tutorial_ok_pressed() -> void:
	tutorial_progress += 1
	
	if is_marauder:
		tutorial_box.get_node("Text").set_string_id("tutorial_battle_loot_" + str(tutorial_progress))
		if tutorial_progress == 4:
			tutorial_box.visible = false
		return
	
	if tutorial_progress == 2:
		tutorial_box.get_node("OK").disabled = true
	elif tutorial_progress == 3:
		tutorial_box.get_node("OK").disabled = false
	elif tutorial_progress == 4:
		tutorial_box.get_node("OK").disabled = true
	elif tutorial_progress == 5:
		tutorial_box.get_node("OK").disabled = false
	elif tutorial_progress == 6:
		tutorial_box.get_node("OK").disabled = true
	elif tutorial_progress == 7:
		tutorial_box.get_node("OK").disabled = false
	elif tutorial_progress == 9:
		tutorial_box.visible = false
	tutorial_box.get_node("Text").set_string_id("tutorial_battle_" + str(tutorial_progress))
