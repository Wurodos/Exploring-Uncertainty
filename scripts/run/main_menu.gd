extends Node

const game_scene = preload("res://scenes/game.tscn")

func _ready() -> void:
	get_node("Language_" + TranslationServer.get_locale()).disabled = true
	Metaprogress.completed_tutorial = true
	#if not CurrentRun.has_save_file():
	# 	$Continue.visible = false
	
	SignalBus.locale_changed.emit()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/draft.tscn")

func _on_switch_language(lang: String):
	get_node("Language_" + TranslationServer.get_locale()).disabled = false
	TranslationServer.set_locale(lang)
	get_node("Language_" + lang).disabled = true
	
	SignalBus.locale_changed.emit()
	
	CurrentRun.config.set_value("prefs", "language", lang)
	CurrentRun.config.save("user://prefs.cfg")


func _on_tutorial_pressed() -> void:
	CurrentRun.is_tutorial = true
	CurrentRun.is_battle_tutorial = true
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
	


## DEBUG

func _on_save_pressed() -> void:
	CurrentRun.save_game()


func _on_load_pressed() -> void:
	CurrentRun.load_save()
	CurrentRun.is_saved_game = true
	get_tree().change_scene_to_file("res://scenes/draft.tscn")
	


func _on_reset_progress_pressed() -> void:
	Metaprogress.reset_progress()


func _on_testing_pressed() -> void:
	CurrentRun.is_debug = true
	CurrentRun.evil_boys = []
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
