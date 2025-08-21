extends TextureRect

class_name ItemShop

var held: Item
var held_slave: Slave

var cost: int

var is_sell: bool

signal sell(ItemShop)
signal buy(ItemShop)

@warning_ignore("shadowed_variable")
func apply(item: Item, is_sell: bool) -> void:
	held = item
	self.is_sell = is_sell
	self.cost = item.cost

	$Cost.text = str(cost)
	texture = held.texture
	
	var color : Color
	match(item.type):
		Item.Type.Weapon: color = Color(1,0,0,0.2)
		Item.Type.Hat: color = Color(0,0,1,0.2)
		Item.Type.Trinket: color = Color(0,1,0,0.2)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	$Clickable.add_theme_stylebox_override("normal", style_box)

func apply_slave(slave: Slave) -> void:
	held_slave = slave
	self.is_sell = false
	self.cost = slave.get_cost()
	
	$Cost.text = "%d\n\n%d/%d" % [cost, slave.hp, slave.maxhp]
	texture = slave.texture
	
	

func toggle(active: bool) -> void:
	$Clickable.disabled = not active 

func _on_clickable_pressed() -> void:
	if is_sell: sell.emit(self)
	else: buy.emit(self)


func _on_clickable_mouse_entered() -> void:
	SignalBus.show_item_info.emit(held)


func _on_clickable_mouse_exited() -> void:
	SignalBus.hide_item_info.emit()
