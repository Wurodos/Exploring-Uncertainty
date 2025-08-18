extends Node

@export var music: Dictionary[StringName, AudioStream] = {}

@onready var _sfx_players: Array[AudioStreamPlayer] = [$Sound, $Sound2, $Sound3]

func _ready() -> void:
	SignalBus.play_music.connect(_on_play_music)
	SignalBus.play_sound.connect(_on_play_sound)
	SignalBus.stop_music.connect(_on_stop_music)

func _on_play_music(track: String):
	$Music.stream = music[track]
	$Music.play()

func _on_stop_music():
	$Music.stop()

func _on_play_sound(track: String):
	for sfx_player: AudioStreamPlayer in _sfx_players:
		if not sfx_player.playing:
			sfx_player.stream = music[track]
			sfx_player.play()
			break
