extends Label

class_name LabelLocalized

@export var string_id: StringName

func _ready() -> void:
	if string_id.is_empty(): return
	
	SignalBus.locale_changed.connect(_localize)
	_localize()

func set_string_id(new_id: StringName) -> void:
	string_id = new_id
	_localize()

func _localize() -> void:
	text = tr(string_id)
