extends LabelLocalized

class_name Typewriter

var full_text : String = ""
var tw_delay: float = 0.1

var _char_pos: int = 0

func type():
	_char_pos = 0
	for char in full_text:
		text += char
		await get_tree().create_timer(tw_delay).timeout
