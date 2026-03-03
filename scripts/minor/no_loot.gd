extends Control

@export var animation: AnimationPlayer

var is_mouse := false

func _ready() -> void:
	SignalBus.mouse_right_up.connect(_on_right_click)

func _on_right_click() -> void:
	if is_mouse:
		visible = false

func _on_mouse_entered() -> void:
	animation.play("glow")
	is_mouse = true
	$Reminder.visible = true


func _on_mouse_exited() -> void:
	animation.play_backwards("glow")
	is_mouse = false
	$Reminder.visible = false
