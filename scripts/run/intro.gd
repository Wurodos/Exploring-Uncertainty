extends Control

enum Phase {
	Start,
	Story,
	TutorialChoice
}

var phase: Phase = Phase.Start

@export var warning_delay: float = 3
@export var hide_warning: AnimationPlayer

func _ready() -> void:
	if not Metaprogress.completed_tutorial:
		warning()
		await hide_warning.animation_finished
		$Warning.visible = false
		$Numbers.stop()
	story()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and phase == Phase.Story:
		if $Story/Typewriter.is_typing:
			$Story/Typewriter.skip()
		else:
			$StoryMusic.stop()
			$Story.visible = false
			if Metaprogress.completed_tutorial:
				_on_no_tutorial_pressed()
			else:
				tutorial_choice()

func warning() -> void:
	$Warning.visible = true
	$Numbers.play()
	await get_tree().create_timer(warning_delay).timeout
	hide_warning.play("hide")

func story() -> void:
	$StoryMusic.play()
	$Story.visible = true
	$Story/Typewriter.type()
	phase = Phase.Story

func tutorial_choice() -> void:
	$TutorialChoice.visible = true


func _on_no_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_tutorial_pressed() -> void:
	pass # Replace with function body.
