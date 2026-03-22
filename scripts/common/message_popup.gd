extends Control

func apply(text: String) -> void:
	$FakeLabel.text = text
	$FlyingLabel.text = text

func destroy(_name: StringName) -> void:
	queue_free()
