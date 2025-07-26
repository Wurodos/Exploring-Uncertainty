extends Control

class_name SlaveTeamNode

var held: Slave
static var selected: SlaveTeamNode

func apply(slave: Slave, show_hp: bool = true):
	held = slave
	$Body.texture = slave.texture
	$Weapon.texture = slave.weapon.texture
	$Hat.texture = slave.hat.texture
	$Trinket1.texture = slave.trinket1.texture
	$Trinket2.texture = slave.trinket2.texture
	
	if show_hp:
		$HPBar.value = (slave.hp / float(slave.maxhp)) * 100
		$HPBar/Label.text = str(slave.hp) + "/" + str(slave.maxhp)
	else:
		$Undress.visible = false
		$HPBar.visible = false

func _on_undress_pressed() -> void:
	var old_items : Array[Item] = []
	
	old_items.append(held.equip(ItemPool.fetch("no_weapon")))
	if held.hat.extra_hp < held.hp:
		old_items.append(held.equip(ItemPool.fetch("no_hat")))
	old_items.append(held.equip(ItemPool.fetch("no_trinket"), 1))
	old_items.append(held.equip(ItemPool.fetch("no_trinket"), 2))
	apply(held)
	
	for item: Item in old_items:
		if item.is_item():
			CurrentRun.inventory.append(item)
			SignalBus.add_item.emit(item)
	
	


func _on_mouse_entered() -> void:
	selected = self
	print("selected slave!")


func _on_mouse_exited() -> void:
	selected = null
	print("unselected")
