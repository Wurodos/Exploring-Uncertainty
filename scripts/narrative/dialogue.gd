extends Control
class_name Dialogue

@export var lines: Array[DialogueNode] = []

@onready var window: DialogueWindow = $DialogueWindow

var current_line: DialogueNode
var prev_state: Game.State


func _ready() -> void:
	SignalBus.new_message.connect(on_new_message)
	SignalBus.end_battle.connect(func(): on_new_message(1), CONNECT_ONE_SHOT)

func on_new_message(id: int) -> void:
	if CurrentRun.is_debug or CurrentRun.is_tutorial: return
	$AnimationPlayer.play("popup")
	window.reset()
	prev_state = CurrentRun.state
	CurrentRun.state = Game.State.Phone
	mouse_filter = Control.MOUSE_FILTER_STOP
	current_line = lines[id]
	$Ring.play()

func say() -> void:
	window.say(current_line)

func return_to_gameplay() -> void:
	CurrentRun.state = prev_state
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide_dialogue()

func show_dialogue() -> void:	
	$AnimationPlayer.play_backwards("popup")
	$Ring.stop()
	
	toggle(true)
	say()

func hide_dialogue() -> void:
	toggle(false)

func toggle(on: bool) -> void:
	window.visible = on


func _on_start_timer_timeout() -> void:
	on_new_message(0)
		
func _on_accept_pressed() -> void:
	show_dialogue()


func _on_continue_pressed() -> void:
	if not window.bubble: return
	
	if window.bubble.get_typewriter().is_typing: 
		window.bubble.get_typewriter().skip()
	else:
		if current_line.next() == null:
			return_to_gameplay()
		else:
			current_line = current_line.next()
			say()
