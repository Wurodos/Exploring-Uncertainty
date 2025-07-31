extends Camera2D

@export var speed : float
@export var bound : float

var current_speed : float

func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_SHIFT):
		current_speed = speed * 2
	else: current_speed = speed
	
	if Input.is_action_pressed("down"):
		position.y = min(position.y + current_speed*delta, bound)
	elif Input.is_action_pressed("up"):
		position.y = max(position.y - current_speed*delta, -bound)
	if Input.is_action_pressed("right"):
		position.x = min(position.x + current_speed*delta, bound)
	elif Input.is_action_pressed("left"):
		position.x = max(position.x - current_speed*delta, -bound)
