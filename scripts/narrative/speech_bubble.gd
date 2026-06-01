extends Control

class_name SpeechBubble

func say(dialogue_node: DialogueNode) -> void:
	%Text.full_text = tr(dialogue_node.text_id)
	%Text.type()

func get_typewriter() -> Typewriter:
	return %Text
