extends RichLocalized
class_name RichTypeWriter

@export var start_typing: bool = false
@export var tw_delay: float = 0.03
@export var chars: int = 1

var full_text : String = ""
var typed_text: String = ""

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
	typed_text = ""
	var index := 0
	var is_color := false
	while index < full_text.length():
		if not is_typing: break
		
		var c = full_text[index]
		var delay := tw_delay
		if c == "$":
			delay = 1
		elif c == "[":
			var bracket_id := index
			
			is_color = full_text[bracket_id+1] != "/"
			
			delay = 0
			while bracket_id < full_text.length() and full_text[bracket_id] != "]":
				typed_text += full_text[bracket_id]
				bracket_id += 1
			typed_text += full_text[bracket_id]
			index = bracket_id
		else:
			typed_text += c
			text = typed_text
			if is_color:
				text += "[/color]"
		index += 1
		_char_pos += 1
		if c == "$" or _char_pos % chars == 0:
			await get_tree().create_timer(delay).timeout
	is_typing = false

func skip() -> void:
	is_typing = false
	text = full_text.replace("$", "")
