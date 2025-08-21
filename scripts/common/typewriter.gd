extends LabelLocalized

class_name Typewriter

var full_text : String = ""
var tw_delay: float = 0.03

var _char_pos: int = 0
var is_typing: bool = false

func _ready() -> void:
	full_text = text
	text = ""

func set_string_id(id: StringName) -> void:
	string_id = id
	full_text = tr(id)

func type():
	text = ""
	_char_pos = 0
	is_typing = true
	for char in full_text:
		if not is_typing: break
		
		text += char
		await get_tree().create_timer(tw_delay).timeout
	is_typing = false
