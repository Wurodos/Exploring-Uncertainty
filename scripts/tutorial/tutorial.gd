extends Control

@export var slave_item_animation: AnimationPlayer
@export var slave_opacity: AnimationPlayer
@export var slave_detached: Control
@export var slave_pos_scale: Control

var current: int = 0

func _ready() -> void:
	$Text.set_string_id("tutorial_new_0")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).pressed:
			continue_tutorial()

func toggle_input(active: bool):
	if active: mouse_filter = Control.MOUSE_FILTER_STOP
	else: mouse_filter = Control.MOUSE_FILTER_IGNORE

func continue_tutorial() -> void:
	current += 1
	$Text.set_string_id("tutorial_new_"+str(current))
	toggle_input(false)
	$SkipCooldown.start()
	match(current):
		2: slave_item_animation.play("appear")
		3: detach_slave()
	
func detach_slave() -> void:
	slave_item_animation.play_backwards("appear")
	slave_detached.reparent(slave_detached.get_parent().get_parent())
	var tween = get_tree().create_tween()
	slave_opacity.play("opacity")
	tween.tween_property(slave_detached, "position", slave_pos_scale.position, 0.5)
	tween.parallel().tween_property(slave_detached, "scale", slave_pos_scale.scale, 0.5)

func _on_skip_cooldown_timeout() -> void:
	toggle_input(true)
