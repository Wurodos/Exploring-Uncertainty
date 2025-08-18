extends Button

class_name ButtonLocalized

@export var string_id: StringName

func _ready() -> void:
	SignalBus.locale_changed.connect(_localize)
	_localize()

func _localize() -> void:
	text = tr(string_id)
