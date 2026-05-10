extends Control
class_name Dialogue

@export var lines: Array[DialogueNode] = []

@onready var portrait_rect: TextureRect = $Speaker/Portrait
@onready var speaker_name: Label = $Speaker/Name
@onready var typewriter: RichTypeWriter = $BG/Text 

var current_line: DialogueNode
var prev_state: Game.State

func _ready() -> void:
	SignalBus.new_message.connect(on_new_message)

func on_new_message(id: int) -> void:
	prev_state = CurrentRun.state
	CurrentRun.state = Game.State.Phone
	mouse_filter = Control.MOUSE_FILTER_STOP
	current_line = lines[id]
	$RingParticle.emitting = true
	$Show.disabled = false
	$Ring.play()

func say() -> void:
	portrait_rect.texture = current_line.portrait
	speaker_name.text = tr(current_line.name_id)
	var old_text = typewriter.full_text
	typewriter.full_text = tr(current_line.text_id)
	if old_text != typewriter.full_text:
		typewriter.type()

func return_to_gameplay() -> void:
	CurrentRun.state = prev_state
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide_dialogue()

func show_dialogue() -> void:
	$RingParticle.emitting = false
	$Ring.stop()
	toggle(true)
	say()

func hide_dialogue() -> void:
	toggle(false)

func toggle(on: bool) -> void:
	$Speaker.visible = on
	$BG.visible = on
	$Show.visible = not on


func _on_start_timer_timeout() -> void:
	if CurrentRun.is_debug or CurrentRun.is_tutorial: return
	on_new_message(0)


func _on_got_it_pressed() -> void:
	if typewriter.is_typing:
		typewriter.skip()
	else:
		
		if current_line.next() == null:
			return_to_gameplay()
		else:
			current_line = current_line.next()
			say()
		
