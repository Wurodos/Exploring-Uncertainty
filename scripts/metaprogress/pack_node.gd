extends Node
class_name PackNode

@export var pack: Pack

func _ready() -> void:
	%Title.set_string_id("pack_" + pack.u_name + "_title")
	
	if not pack.check_unlocked():
		$Pick.disabled = true
		%ToUnlock.visible = true
		%Description.set_string_id("pack_" + pack.u_name + "_unlock")
	else:
		%ToUnlock.visible = false
		%Description.set_string_id("pack_" + pack.u_name + "_desc")
	
	var i := 0
	for back: ColorRect in %Items.get_children():
		if i >= pack.items.size():
			back.visible = false
		else:
			back.color = Constants.item_colors[pack.items[i].type]
			(back.get_node("Icon") as TextureRect).texture = pack.items[i].texture
		i += 1

func _on_pick_pressed() -> void:
	SignalBus.pick_pack.emit(pack)
