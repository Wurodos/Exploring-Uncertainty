extends Control

class_name SlaveTeamNode

enum Type {Brigade, City, Govnov}

var held: Slave
var type: Type
static var selected: SlaveTeamNode

signal sell

func apply(slave: Slave, type: Type, show_hp: bool = true):
	held = slave
	self.type = type
	$Body.texture = slave.texture
	$Weapon.texture = slave.weapon.texture
	$Hat.texture = slave.hat.texture
	$Trinket1.texture = slave.trinket1.texture
	$Trinket2.texture = slave.trinket2.texture
	
	match (type):
		Type.Brigade:
			$Undress.text = "Раздеть"
			if not $Undress.is_connected("pressed", _on_undress_pressed):
				$Undress.pressed.connect(_on_undress_pressed)
		Type.City:
			$Undress.text = "Лечить"
			if not $Undress.is_connected("pressed", _on_heal_pressed):
				$Undress.pressed.connect(_on_heal_pressed)
		Type.Govnov:
			$Sell.visible = true
			$Sell.text = "Продать\n(%d)" % held.get_cost()
			$Undress.text = "Лечить"
			if not $Undress.is_connected("pressed", _on_govnov_heal_pressed):
				$Undress.pressed.connect(_on_govnov_heal_pressed)
	
	if show_hp:
		$HPBar.value = (slave.hp / float(slave.maxhp)) * 100
		$HPBar/Label.text = str(slave.hp) + "/" + str(slave.maxhp)
	else:
		$Undress.visible = false
		$HPBar.visible = false

func update_healing_cost(heals_used: int, value: int) -> void:
	if value < heals_used * 10:
		$Undress.disabled = true
	else: 
		$Undress.disabled = false
		
	$Undress.text = "Лечить"
	if heals_used > 0:
		$Undress.text += "\n(" + str(heals_used*10) + ")"

func _on_undress_pressed() -> void:
	var old_items : Array[Item] = []
	
	old_items.append(held.equip(ItemPool.fetch("no_weapon")))
	if held.hat.extra_hp < held.hp:
		old_items.append(held.equip(ItemPool.fetch("no_hat")))
	old_items.append(held.equip(ItemPool.fetch("no_trinket"), 1))
	old_items.append(held.equip(ItemPool.fetch("no_trinket"), 2))
	apply(held, type)
	
	for item: Item in old_items:
		if item.is_item():
			CurrentRun.inventory.append(item)
			SignalBus.add_item.emit(item)
	
func _on_heal_pressed() -> void:
	held.hp = held.maxhp
	$HPBar.value = (held.hp / float(held.maxhp)) * 100
	$HPBar/Label.text = str(held.hp) + "/" + str(held.maxhp)
	
	SignalBus.city_heal.emit()

func _on_govnov_heal_pressed() -> void:
	held.hp = held.maxhp
	$HPBar.value = (held.hp / float(held.maxhp)) * 100
	$HPBar/Label.text = str(held.hp) + "/" + str(held.maxhp)
	
	SignalBus.govnov_heal.emit()

func _on_mouse_entered() -> void:
	selected = self
	print("selected slave!")


func _on_mouse_exited() -> void:
	selected = null
	print("unselected")


func _on_sell_pressed() -> void:
	sell.emit()
