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
var current_slaves: Array[Slave] = []

var selected_sender: SlaveNode
var selected_victim: SlaveNode

var is_line : bool = false
var is_marauder : bool = false
var is_first_round : bool = true

var tutorial_progress: int = 0

func get_queue_element(id: int) -> QueueElement:
	return queue_node.get_child(speed_queue.size() - 1 - id)

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
	# Vigilance
	for boy in good_team.boys_nodes: 
		if boy.held.is_alive:
			boy.vigilance = boy.viable_for_vigilance
			boy.viable_for_vigilance = true
	for boy in evil_team.boys_nodes: 
		if boy.held.is_alive:
			boy.vigilance = boy.viable_for_vigilance
			boy.viable_for_vigilance = true
	
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
	
	
	var copy = speed_queue.duplicate()
	copy.reverse()
	for slave : Slave in copy:
		var new_element : QueueElement = queue_element.instantiate()
		new_element.apply(slave)
		queue_node.add_child(new_element)

func _compare_speeds(slave_1: Slave, slave_2: Slave) -> bool:
	return slave_1.speed > slave_2.speed

func _on_new_turn() -> void:
	for child in queue_node.get_children():
		child.toggle_select(false)
	
	current_slave_position += 1
	
	
	if current_slave_position >= queue_node.get_child_count():
		for slave : SlaveNode in good_team.boys_nodes:
			slave.ticker_down_buffs()
		for slave : SlaveNode in evil_team.boys_nodes:
			slave.ticker_down_buffs()
		SignalBus.new_round.emit()
	else:
		if not speed_queue[current_slave_position].is_alive:
			_on_new_turn()
			return
	
	
	
	# If there are friendly slaves going in a row, player should be able to choose
	
	current_slaves = []
	for i in range(current_slave_position, speed_queue.size()):
		var slave = speed_queue[i]
		if slave is Enemy: break
		if not slave.is_alive: continue
		current_slaves.append(slave)
		get_queue_element(i).toggle_select(true)
	
	if speed_queue[current_slave_position] is Enemy:
		get_queue_element(current_slave_position).toggle_select(true)
		for slave_node in evil_team.boys_nodes:
			if speed_queue[current_slave_position] == slave_node.held:
				slave_node.start_turn()
				slave_node.execute_intention()
				break
	else:
		for slave_node in good_team.boys_nodes:
			if current_slaves.has(slave_node.held):
				slave_node.start_turn()

func _on_slave_death(slave_node: SlaveNode, is_loot: bool = true) -> void:
	if slave_node.held is Enemy:
		var dude : Enemy = slave_node.held
		if dude.is_final_boss:
			$AnimationPlayer.play("win")
			SignalBus.new_turn.disconnect(_on_new_turn)
			return
	else:
		current_slaves.erase(slave_node.held)
	
	if is_loot:
		for item : Item in slave_node.get_all_items():
			if item.is_item():
				loot_node.items.append(item)
	
	for i in range(speed_queue.size()):
		if speed_queue[i] == slave_node.held:
			get_queue_element(i).visible = false
			if i == current_slave_position:
				slave_node.toggle_arrow(false)
			break
	
	if good_team.boys.is_empty():
		SignalBus.evil_won.emit()
	elif evil_team.boys.is_empty():
		SignalBus.good_won.emit()
	
	if current_slave_position > speed_queue.size():
		SignalBus.new_turn.emit()
	elif not speed_queue[current_slave_position] is Enemy and not slave_node.held is Enemy:
		if current_slaves.is_empty():
			SignalBus.new_turn.emit()
		else: current_slave_position += 1

func _on_slave_selected(slave_node: SlaveNode) -> void:
	if is_marauder: return
	if current_slaves.has(slave_node.held) and not slave_node.team.is_evil:
		slave_node.toggle_ellipse(true)
		selected_sender = slave_node
		is_line = true
		_on_slave_mouse_entered(slave_node)

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
		
		if selected_sender != null:
			get_queue_element(speed_queue.find(selected_sender.held)).toggle_select(false)
		
		current_slaves.erase(selected_sender.held)
		if current_slaves.is_empty():
			SignalBus.new_turn.emit()
		else: current_slave_position += 1

func _on_slave_mouse_entered(slave_node: SlaveNode):
	if is_line:
		if not slave_node.team.is_evil and slave_node != selected_sender \
			and (selected_sender.held.hat.target == Item.Target.Self or selected_sender.buffs.has(Action.DARK)):
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
	if current_slaves.has(slave): return
	
	var slave_node = _find_slave_node(slave)
	slave_node.arrow.visible = true
	slave_node.arrow_animation.play("bounce")

func _on_speed_queue_mouse_exited(slave: Slave):
	if current_slaves.has(slave): return
	var slave_node = _find_slave_node(slave)
		
	slave_node.arrow.visible = false
	slave_node.arrow_animation.play("RESET")

func _on_good_won() -> void:
	print("Good won!")
	is_marauder = true
	CurrentRun.good_boys = CurrentRun.good_boys.filter(func(slave: Slave): return slave.is_alive)
	SignalBus.stop_music.emit()
	
	# Level up items
	
	for slave : Slave in CurrentRun.good_boys:
		slave.speed = slave.base_speed
		for item : Item in [slave.weapon, slave.hat, slave.trinket1, slave.trinket2]:
			item.on_end_battle(slave)
			if item.is_item() and item.level < 5:
				item.experience += 1
				if item.experience == Constants.exp_required[item.level-1]:
					item.experience = 0
					item.level += 1
					item.on_level_up()
	
	loot_node.visible = true
	loot_node.start_marauder()
	
	
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


func _on_go_back_map_pressed() -> void:
	CurrentRun.is_battle_tutorial = false
	SignalBus.end_battle.emit()
