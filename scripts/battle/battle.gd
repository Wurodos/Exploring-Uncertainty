extends Node2D

class_name Battle

static var instance: Battle

@onready var good_team: Team = $World/GoodTeam
@onready var evil_team: Team = $World/EvilTeam
@onready var queue_node: Control = $UI/SpeedQueue
@onready var line2d : Line2D = $World/Line2D

const queue_element = preload("res://prefabs/battle/queue_element.tscn")

var speed_queue: Array[Slave] = []
var current_slave_position : int = 0
var current_slave: Slave

var selected_sender: SlaveNode
var selected_victim: SlaveNode

var is_line : bool = false

func _ready() -> void:
	instance = self
	SignalBus.start_battle.connect(_on_start_battle)
	SignalBus.new_round.connect(_on_new_round)
	SignalBus.new_turn.connect(_on_new_turn)
	SignalBus.mouse_dragged.connect(_on_mouse_dragged)
	SignalBus.mouse_up.connect(_on_mouse_released)
	SignalBus.slave_selected.connect(_on_slave_selected)
	SignalBus.slave_mouse_entered.connect(_on_slave_mouse_entered)
	SignalBus.slave_mouse_exited.connect(_on_slave_mouse_exited)
	SignalBus.slave_death.connect(_on_slave_death)
	
	SignalBus.evil_won.connect(_on_evil_won)
	SignalBus.good_won.connect(_on_good_won)
	
	CurrentRun.good_boys = [SlavePool.fetch("blob"), SlavePool.fetch("blob"), SlavePool.fetch("blob")]
	CurrentRun.evil_boys = [SlavePool.fetch("cherv"), SlavePool.fetch("cherv")]
	CurrentRun.good_boys[0].equip(ItemPool.fetch("crown"))
	CurrentRun.good_boys[0].equip(ItemPool.fetch("bomb"))
	CurrentRun.good_boys[1].equip(ItemPool.fetch("pipe"))
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
		SignalBus.new_round.emit()
	queue_node.get_child(current_slave_position).toggle_select(true)
	current_slave = speed_queue[current_slave_position]
	
	if current_slave is Enemy:
		for slave_node in evil_team.boys_nodes:
			if slave_node.held == current_slave:
				slave_node.execute_intention()
				break

func _on_slave_death(slave_node: SlaveNode) -> void:
	for i in range(speed_queue.size()):
		if speed_queue[i] == slave_node.held:
			queue_node.get_child(i).free()
			speed_queue.remove_at(i)
			break			

func _on_slave_selected(slave_node: SlaveNode) -> void:
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
			line2d.points = [selected_sender.line_start, line2d.to_local(pos)]
	
func _on_mouse_released():
	is_line = false
	line2d.points = []
	if selected_victim:
		if selected_victim.team.is_evil:
			selected_sender.attack(selected_victim)
		else:
			selected_sender.support(selected_victim)
		selected_victim = null
		SignalBus.new_turn.emit()

func _on_slave_mouse_entered(slave_node: SlaveNode):
	if is_line:
		if not slave_node.team.is_evil and slave_node != selected_sender and selected_sender.held.hat.target == Item.Target.Self:
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


func _on_good_won() -> void:
	print("Good won!")

func _on_evil_won() -> void:
	print("Evil won!")

# ====================
# Debug panel
# ====================

func _on_newturn_pressed() -> void:
	SignalBus.new_turn.emit()
