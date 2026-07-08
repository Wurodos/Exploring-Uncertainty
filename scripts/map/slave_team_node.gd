extends Control

class_name SlaveTeamNode

enum Type {Brigade, City, Govnov, OnlyItems, BrigadeTutorial}

var held: Slave
var type: Type
static var selected: SlaveTeamNode

@export var default_type: Type = Type.Brigade

@onready var btn_sell: Button = $Sell

signal sell

@warning_ignore("shadowed_variable")
func apply(slave: Slave, type: Type, show_hp: bool = true):
	if slave == null: 
		visible = false
		return
	if not type: type = default_type
	held = slave
	self.type = type
	$Body.texture = slave.texture
	$Weapon.texture = slave.weapon.texture
	$Weapon.set_instance_shader_parameter("outline_color", Constants.level_colors[slave.weapon.level])
	$Hat.texture = slave.hat.texture
	$Hat.set_instance_shader_parameter("outline_color", Constants.level_colors[slave.hat.level])
	$Trinket1.texture = slave.trinket1.texture
	$Trinket1.set_instance_shader_parameter("outline_color", Constants.level_colors[slave.trinket1.level])
	$Trinket2.texture = slave.trinket2.texture
	$Trinket2.set_instance_shader_parameter("outline_color", Constants.level_colors[slave.trinket2.level])
	$Trinket3.texture = slave.trinket3.texture
	$Trinket3.set_instance_shader_parameter("outline_color", Constants.level_colors[slave.trinket2.level])
	
	
	match (type):
		Type.Brigade:
			$Undress.text = tr("undress")
			if not $Undress.is_connected("pressed", _on_undress_pressed):
				$Undress.pressed.connect(_on_undress_pressed)
		Type.BrigadeTutorial:
			$Undress.visible = false
		Type.City:
			$Undress.text = tr("heal")
			if not $Undress.is_connected("pressed", _on_heal_pressed):
				$Undress.pressed.connect(_on_heal_pressed)
		Type.Govnov:
			$Sell.visible = true
			$Sell.text = tr("sell") + "\n(" + str(held.get_cost()) + ")"
			$Undress.text = tr("heal")
			if not $Undress.is_connected("pressed", _on_govnov_heal_pressed):
				$Undress.pressed.connect(_on_govnov_heal_pressed)
		Type.OnlyItems:
			$Undress.visible = false
			$HPBar.visible = false
		
	if show_hp:
		$HPBar.value = (slave.hp / float(slave.maxhp)) * 100
		$HPBar/Label.text = str(slave.hp) + "/" + str(slave.maxhp)
	else:
		$Undress.visible = false
		$HPBar.visible = false
	
	visible = true

func update_healing_cost(heals_used: int, value: int, heal_price: int) -> void:
	if value < heals_used * heal_price:
		$Undress.disabled = true
	else: 
		$Undress.disabled = false
		
	$Undress.text = tr("heal")
	if heals_used > 0:
		$Undress.text += "\n(" + str(heals_used*heal_price) + ")"

func _on_undress_pressed() -> void:
	var old_items: Array[Item] = held.undress()
	apply(held, type)
	
	for item: Item in old_items:
		if item.is_item():
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
	if ItemDraggable.selected:
		pass


func _on_mouse_exited() -> void:
	selected = null


func _on_sell_pressed() -> void:
	sell.emit()
