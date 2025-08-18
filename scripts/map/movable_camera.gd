extends Camera2D

@export var speed : float
@export var drag_multiplier: float
@export var bound : float

var current_speed : float

func _ready() -> void:
	SignalBus.mouse_delta.connect(_on_mouse_dragged)

func _on_mouse_dragged(delta: Vector2):
	if CurrentRun.state == Game.State.Map:
		delta *= drag_multiplier
		position.x = clamp(position.x - delta.x, -bound, bound)
		position.y = clamp(position.y - delta.y, -bound, bound)

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
