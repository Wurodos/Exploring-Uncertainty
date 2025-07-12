extends Node2D

class_name SlaveNode

signal received_damage(source: SlaveNode, dmg: int)
signal hp_changed
signal turn_ended
signal turn_started
signal attacked(victim: SlaveNode)

@onready var line_start: Vector2 = $CircleSelect/LineStart.global_position
@onready var line_end: Vector2 = $CircleSelect/LineEnd.global_position
@onready var ellipse: Sprite2D = $CircleSelect
@onready var stat_parent: Control = $Stats

const item_prefab = preload("res://prefabs/items/item.tscn")
const stat_entry_prefab = preload("res://prefabs/battle/stat_entry.tscn")

var is_mouse_over: bool = false
var held: Slave
var sprite: Sprite2D
var team: Team

var weapon_node: ItemNode
var hat_node: ItemNode
var trinket1_node: ItemNode
var trinket2_node: ItemNode

# name -> turns left
var buffs : Dictionary[String, int] = {}
var power : int = 0
var luck : int = 0

func _ready() -> void:
	SignalBus.mouse_up.connect(_on_mouse_up)
	SignalBus.mouse_right_down.connect(_on_mouse_right_down)
	if held is Enemy:
		SignalBus.new_round.connect(_decide_intentions)

func remove_item(u_name: StringName) -> void:
	var i = 0
	for item : Item in get_all_items():
		i += 1
		if item.u_name == u_name:
			match item.type:
				Item.Type.Weapon:
					held.equip(ItemPool.fetch("no_weapon"))
					weapon_node.apply(held.weapon)
				Item.Type.Hat:
					held.equip(ItemPool.fetch("no_hat"))
					hat_node.apply(held.hat)
				Item.Type.Trinket:
					var tr_id = 1
					if i == 4: tr_id = 2
					held.equip(ItemPool.fetch("no_trinket"), tr_id)
					
					if tr_id == 1: trinket1_node.apply(held.trinket1)
					else: trinket2_node.apply(held.trinket2)
			return	

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
	else: hp_changed.emit()

func set_speed(new_val: int, is_delta: bool = true):
	if is_delta:
		held.speed += new_val
	else: held.speed = new_val
	add_stat("speed", Gallery.icon_speed, held.speed)
	#Battle.instance.recalculate_speed()

func set_power(new_val: int, is_delta: bool = true):
	if is_delta:
		power += new_val
	else: power = new_val
	add_stat("power", Gallery.icon_power, power)

func set_luck(new_val: int, is_delta: bool = true):
	if is_delta:
		luck += new_val
	else: luck = new_val
	
	add_stat("luck", Gallery.icon_luck, luck)
			
func apply(slave: Slave, is_evil: bool = false) -> void:
	held = slave
	sprite = $Sprite
	sprite.texture = slave.texture
	
	if is_evil: 
		sprite.flip_h = true
		for offset_node: Node2D in $Items.get_children():
			offset_node.position.x *= -1
		
	
	weapon_node = item_prefab.instantiate()
	$Items/Weapon.add_child(weapon_node)
	weapon_node.apply(held.weapon, is_evil)
	
	hat_node = item_prefab.instantiate()
	$Items/Hat.add_child(hat_node)
	hat_node.apply(held.hat, is_evil)
	
	trinket1_node = item_prefab.instantiate()
	$Items/Trinket1.add_child(trinket1_node)
	trinket1_node.apply(held.trinket1, is_evil)
	
	trinket2_node = item_prefab.instantiate()
	$Items/Trinket2.add_child(trinket2_node)
	trinket2_node.apply(held.trinket2, is_evil)

func add_stat(stat_name: String, icon: Texture2D, value: int):
	var stat_entry : StatEntry = stat_parent.find_child(stat_name, false, false)
	if stat_entry == null:
		stat_entry = stat_entry_prefab.instantiate()
		stat_entry.texture = icon
		stat_entry.name = stat_name
		stat_entry.init()
		stat_parent.add_child(stat_entry)
	stat_entry.label.text = str(value)

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
	attacked.emit(victim)
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

func start_turn() -> void:
	turn_started.emit()

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
		if buffs[key] == 0: to_be_erased.append(key)
	
	for key in to_be_erased:
		var visual : Node2D = $Buffs.find_child(key)
		if visual: visual.visible = false
		
		buffs.erase(key)
		
	turn_ended.emit()
	

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
