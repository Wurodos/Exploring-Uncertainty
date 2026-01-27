extends LabelLocalized
class_name LabelAutosize

@export var max_font_size = 56


func _ready() -> void:
	clip_text = true
	item_rect_changed.connect(_on_item_rect_changed)


func _set(property: StringName, _value: Variant) -> bool:
	match property:
		"text":
			# listen for text changes
			update_font_size()

	return false


func update_font_size() -> void:
	var font = label_settings.font
	var font_size = label_settings.font_size

	var line = TextLine.new()
	line.direction = text_direction
	line.flags = justification_flags
	line.alignment = horizontal_alignment

	for i in 20:
		line.clear()
		var created = line.add_string(text, font, font_size)
		if created:
			var text_size = line.get_line_width()

			if text_size > floor(size.x):
				font_size -= 1
			elif font_size < max_font_size:
				font_size += 1
			else:
				break
		else:
			push_warning('Could not create a string')
			break

	var new_label_settings = label_settings.duplicate()
	new_label_settings.font_size = font_size
	label_settings = new_label_settings


func _on_item_rect_changed() -> void:
	update_font_size()
