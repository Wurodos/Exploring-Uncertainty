extends Node2D

class_name SlaveNode

signal received_damage(source: SlaveNode, dmg: int)

@onready var line_start: Vector2 = $CircleSelect/LineStart.global_position
@onready var line_end: Vector2 = $CircleSelect/LineEnd.global_position
@onready var ellipse: Sprite2D = $CircleSelect

const item_prefab = preload("res://prefabs/items/item.tscn")

var is_mouse_over: bool = false
var held: Slave
var sprite: Sprite2D
var team: Team

# name -> turns left
var buffs : Dictionary[String, int] = {}
var power : int = 0

func _ready() -> void:
	SignalBus.mouse_up.connect(_on_mouse_up)
	SignalBus.mouse_right_down.connect(_on_mouse_right_down)
	if held is Enemy:
		SignalBus.new_round.connect(_decide_intentions)

func set_max_hp(new_val: int, is_delta: bool = true):
	if is_delta: held.maxhp += new_val
	else: held.maxhp = new_val
	
	$HPBar.value = (held.hp/float(held.maxhp)*100)

func set_hp(new_val: int, is_delta: bool = true):
	if is_delta: held.hp += new_val
	else: held.hp = new_val
	
	$HPBar.value = (held.hp/float(held.maxhp)*100)
	
	# Death
	if held.hp <= 0 and held.is_alive:
		held.is_alive = false
		sprite.texture = Gallery.img_dead_slave
		$HPBar.visible = false
		$Items.visible = false
		$Intention.visible = false
		SignalBus.slave_death.emit(self)

func set_speed(new_val: int, is_delta: bool = true):
	if is_delta:
		held.speed += new_val
	else: held.speed = new_val
	
	#Battle.instance.recalculate_speed()

func set_power(new_val: int, is_delta: bool = true):
	if is_delta:
		power += new_val
	else: power = new_val
			
func apply(slave: Slave, is_evil: bool = false) -> void:
	held = slave
	sprite = $Sprite
	sprite.texture = slave.texture
	
	if is_evil: 
		sprite.flip_h = true
		for offset_node: Node2D in $Items.get_children():
			offset_node.position.x *= -1
		
	
	var weapon = item_prefab.instantiate()
	$Items/Weapon.add_child(weapon)
	weapon.apply(held.weapon, is_evil)
	
	var hat = item_prefab.instantiate()
	$Items/Hat.add_child(hat)
	hat.apply(held.hat, is_evil)
	
	var trinket1 = item_prefab.instantiate()
	$Items/Trinket1.add_child(trinket1)
	trinket1.apply(held.trinket1, is_evil)
	
	var trinket2 = item_prefab.instantiate()
	$Items/Trinket2.add_child(trinket2)
	trinket2.apply(held.trinket2, is_evil)

func start_battle() -> void:
	for item : Item in [held.weapon, held.hat, held.trinket1, held.trinket2]:
		item.on_start_battle(self)
	
func get_all_items() -> Array[Item]:
	return [held.weapon, held.hat, held.trinket1, held.trinket2]

func toggle_ellipse(visible: bool):
	$CircleSelect.visible = visible

func attack(victim: SlaveNode):
	$AnimationPlayer.play("jump")
	match(held.weapon.target):
		Item.Target.Single: 
			held.weapon.use_item(self, victim)
		Item.Target.AllTeam: 
			for slave in Battle.instance.evil_team.boys_nodes:
				held.weapon.use_item(self, slave)
	_on_end_turn()
	
func support(ally: SlaveNode):
	$AnimationPlayer.play("jump")
	match(held.hat.target):
		Item.Target.Self:
			held.hat.use_item(self, self)
		Item.Target.Single: 
			held.hat.use_item(self, ally)
		Item.Target.AllTeam: 
			for slave in Battle.instance.good_team.boys_nodes:
				held.hat.use_item(self, slave)
	_on_end_turn()

func execute_intention():
	var held_enemy : Enemy = held
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("jump")
	match(held_enemy.intention.type):
		Enemy.Intention.Type.DamageSingular:
			Action.deal_damage(self,\
				Battle.instance.good_team.boys_nodes[held_enemy.intention.target],\
				held_enemy.intention.amount)
			
	_on_end_turn()
	await get_tree().create_timer(1).timeout
	SignalBus.new_turn.emit()

func add_buff(buff_name: String, turns: int):
	if buffs.has(buff_name):
		buffs[buff_name] += turns
	else: buffs.set(buff_name, turns+1)
	# Why +1? To skip the current turn
	
	var visual : Node2D = $Buffs.find_child(buff_name)
	if visual:
		visual.visible = true

func _on_clickable_area_mouse_entered() -> void:
	SignalBus.slave_mouse_entered.emit(self)
	is_mouse_over = true


func _on_clickable_area_mouse_exited() -> void:
	SignalBus.slave_mouse_exited.emit(self)
	is_mouse_over = false

func _on_mouse_up() -> void:
	toggle_ellipse(false)

func _on_mouse_right_down() -> void:
	if is_mouse_over:
		SignalBus.slave_info.emit(self)

func _on_clickable_area_button_down() -> void:
	SignalBus.slave_selected.emit(self)

func _on_end_turn() -> void:
	var to_be_erased : Array[String] = []
	
	for key: String in buffs.keys():
		buffs[key] -= 1
		print(key, buffs[key])
		if buffs[key] == 0: to_be_erased.append(key)
	
	for key in to_be_erased:
		var visual : Node2D = $Buffs.find_child(key)
		if visual: visual.visible = false
		
		buffs.erase(key)
			

# only if evil
func _decide_intentions() -> void:
	var held_enemy : Enemy = held
	held_enemy.decide_intention()
	$Intention/Label.text = str(held_enemy.intention.amount)
	
	var icon: Texture2D 
	
	match(held_enemy.intention.type):
		Enemy.Intention.Type.DamageSingular: 
			icon = Gallery.icon_harm_single
	
	$Intention/TargetTop.visible = false
	$Intention/TargetMiddle.visible = false
	$Intention/TargetBottom.visible = false
	
	match(held_enemy.intention.target):
		Enemy.Intention.Target.Up: $Intention/TargetTop.visible = true
		Enemy.Intention.Target.Middle: $Intention/TargetMiddle.visible = true
		Enemy.Intention.Target.Bottom: $Intention/TargetBottom.visible = true
	
	$Intention/Icon.texture = icon
