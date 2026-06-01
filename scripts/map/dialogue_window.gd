extends Control
class_name DialogueWindow

const speech_bubble_scene = preload("res://prefabs/dialogue/speech_bubble.tscn")

@onready var speaker_row: HBoxContainer = $BG/SpeakerRow

var speaker_count: int = 0
var bubble : SpeechBubble = null
var speakers: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	reset()

func reset() -> void:
	speakers = []
	for speaker: Control in speaker_row.get_children():
		speaker.visible = false

func say(dialogue_node: DialogueNode) -> void:
	var speaker: TextureRect = null
	if bubble: bubble.free()
	if not speakers.has(dialogue_node.name_id):
		speakers.append(dialogue_node.name_id)
		speaker = speaker_row.get_child(speaker_count)
		speaker_count += 1
		speaker.visible = true
		speaker.texture = dialogue_node.portrait
		
		(speaker.get_node("Name") as LabelLocalized).set_string_id(dialogue_node.name_id)
		
		await get_tree().create_timer(0.1).timeout
	else:
		speaker = speaker_row.get_child(speakers.find(dialogue_node.name_id))
		speaker.texture = dialogue_node.portrait
	
	bubble = speech_bubble_scene.instantiate()
	add_child(bubble)
	bubble.global_position = speaker.global_position
	bubble.position.x += speaker.size.x*0.5
	bubble.position.y += speaker.size.y*1.5
	bubble.say(dialogue_node)
