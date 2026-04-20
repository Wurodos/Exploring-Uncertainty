extends Resource
class_name DialogueNode

@export var portrait: Texture2D
@export var name_id: String
@export var text_id: String
@export var next_node: DialogueNode

func next() -> DialogueNode:
	return next_node
