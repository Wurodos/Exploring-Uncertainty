extends Control
class_name ExperienceEntry

@onready var item_name: Label = $ItemName
@onready var experience_bar: ProgressBar = $ExpBar
@onready var experience_label: Label = $ExpBar/Label
@onready var item_icon: TextureRect = $ItemBG/Item
@onready var bg: TextureRect = $BG
@onready var level_border: ColorRect = $LevelBorder

var held: Item = null

func apply(item: Item) -> void:
	item_name.text = item.name
	item_icon.texture = item.texture
	bg.self_modulate = Constants.item_colors[item.type]
	level_border.color = Constants.level_colors[item.level]
	experience_label.text = str(item.experience) + "/" + str(Constants.exp_required[item.level-1])
	experience_bar.max_value = Constants.exp_required[item.level-1]
	experience_bar.value = item.experience
	held = item

func gain_one_exp() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(experience_bar, "value", experience_bar.value + 1, 1)\
		.set_delay(0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): apply(held))
	tween.play()
