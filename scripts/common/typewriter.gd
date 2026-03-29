extends LabelLocalized

class_name Typewriter

@export var start_typing: bool = false
@export var tw_delay: float = 0.03

var full_text : String = ""

var _char_pos: int = 0
var is_typing: bool = false

func _ready() -> void:
	full_text = text
	text = ""
	if start_typing:
		type()

func set_string_id(id: StringName) -> void:
	string_id = id
	full_text = tr(id)

func type():
	text = ""
	_char_pos = 0
	is_typing = true
	for char in full_text:
		if not is_typing: break
		var delay := tw_delay
		if char == "$":
			delay = 1
		else:
			text += char
		await get_tree().create_timer(delay).timeout
	is_typing = false

func skip() -> void:
	is_typing = false
	text = full_text.replace("$", "")
