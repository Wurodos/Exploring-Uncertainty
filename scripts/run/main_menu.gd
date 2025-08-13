extends Node

func _ready() -> void:
	get_node("Language_" + TranslationServer.get_locale()).disabled = true
	$Button.text = tr("prepare")
	$Tutorial.text = tr("tutorial")
	SignalBus.locale_changed.emit()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/draft.tscn")

func _on_switch_language(lang: String):
	get_node("Language_" + TranslationServer.get_locale()).disabled = false
	TranslationServer.set_locale(lang)
	get_node("Language_" + lang).disabled = true
	
	SignalBus.locale_changed.emit()
	$Button.text = tr("prepare")
	$Tutorial.text = tr("tutorial")
	
	CurrentRun.config.set_value("prefs", "language", lang)
	CurrentRun.config.save("user://prefs.cfg")


func _on_tutorial_pressed() -> void:
	CurrentRun.is_tutorial = true
