extends TextureRect

class_name ItemDraggable

static var selected: ItemDraggable 

var is_following_mouse : bool = false
var held: Item

var start_pos: Vector2

func _ready() -> void:
	
	start_pos = position
	SignalBus.mouse_up.connect(_on_mouse_up)

func _process(_delta: float) -> void:
	if is_following_mouse:
		global_position = get_global_mouse_position() - Vector2(26,26)

func snap() -> void:
	position = start_pos
	is_following_mouse = false

func apply(item: Item) -> void:
	held = item
	texture = held.texture

func _on_clickable_button_down() -> void:
	$Clickable.visible = false
	is_following_mouse = true
	selected = self

func _on_mouse_up() -> void:
	$Clickable.visible = true
	is_following_mouse = false	
	selected = null

func _on_clickable_mouse_entered() -> void:
	SignalBus.show_item_info.emit(held)

func _on_clickable_mouse_exited() -> void:
	SignalBus.hide_item_info.emit()
