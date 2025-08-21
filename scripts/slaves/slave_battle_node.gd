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
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow: Sprite2D = $Arrow
@onready var arrow_animation: AnimationPlayer = $ArrowAnimation

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
	$AnimationSprites/Label.text = tr("crit")
	
	SignalBus.mouse_up.connect(_on_mouse_up)
	SignalBus.mouse_right_down.connect(_on_mouse_right_down)
	if held is Enemy:
		SignalBus.new_round.connect(_decide_intentions)
	set_hp(0)

func toggle_arrow(on: bool) -> void:
	if on:
		$Arrow.visible = true
		$ArrowAnimation.play("bounce")
	else:
		$Arrow.visible = false
		$ArrowAnimation.play("RESET")

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
		arrow.visible = false
		SignalBus.slave_death.emit(self)
	else: hp_changed.emit()

func set_speed(new_val: int, is_delta: bool = true):
	if is_delta:
		held.speed += new_val
	else: held.speed = new_val
	add_stat("speed", Gallery.icon_speed, held.speed)
	#Battle.instance.recalculate_speed()

func set_power(new_val: int, is_delta: bool = true):
	var old_val: int = power
	
	if is_delta:
		power += new_val
	else: power = new_val
	
	if power > old_val:
		SignalBus.play_sound.emit("powerup")
	add_stat("power", Gallery.icon_power, power)
	
	animation_player.play("power_up")
	await animation_player.animation_finished
	animation_player.play("idle")

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
	if team.is_evil:
		for item : Item in [held.weapon, held.hat, held.trinket1, held.trinket2]:
			set_speed(item.extra_speed)
	else:
		for item : Item in [held.weapon, held.hat, held.trinket1, held.trinket2]:
			item.on_start_battle(self)
	if team.is_evil:
		var enemy: Enemy = held
		enemy.update_stats(self)
	
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
	toggle_arrow(true)
	turn_started.emit()

func ticker_down_buffs() -> void:
	var to_be_erased : Array[String] = []
	
	for key: String in buffs.keys():
		buffs[key] -= 1
		if buffs[key] == 0: to_be_erased.append(key)
	
	for key in to_be_erased:
		remove_buff(key)

func remove_buff(buff_name: String):
	var visual : Node2D = $Buffs.find_child(buff_name)
	if visual: visual.visible = false
	
	buffs.erase(buff_name)

func execute_intention():
	var held_enemy : Enemy = held
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("jump")
	match(held_enemy.intention.type):
		
		
		Enemy.Intention.Type.DamageSingular:
			Action.deal_damage(self,\
				Battle.instance.good_team.boys_nodes[held_enemy.intention.target],\
				held_enemy.intention.amount)
		
		Enemy.Intention.Type.DamageTwo:
			Action.deal_damage(self,\
				Battle.instance.good_team.boys_nodes[held_enemy.intention.target],\
				held_enemy.intention.amount)
			Action.deal_damage(self,\
				Battle.instance.good_team.boys_nodes[held_enemy.intention.target_second],\
				held_enemy.intention.amount)
		
		Enemy.Intention.Type.DamageMultiple:
			for slave : SlaveNode in Battle.instance.good_team.boys_nodes:
				Action.deal_damage(self, slave, held_enemy.intention.amount)
		
		
		
		Enemy.Intention.Type.HealSingle:
			Action.heal(self,\
				Battle.instance.evil_team.boys_nodes[held_enemy.intention.target],\
				held_enemy.intention.amount)
		
		
		
		Enemy.Intention.Type.HealMultiple:
			for slave : SlaveNode in Battle.instance.evil_team.boys_nodes:
				Action.heal(self, slave, held_enemy.intention.amount)
		
		
		
		Enemy.Intention.Type.PowerUp:
			Battle.instance.evil_team.boys_nodes[held_enemy.intention.target]\
				.set_power(held_enemy.intention.amount)
		
		
		
		Enemy.Intention.Type.Run:
			held.is_alive = false
			sprite.texture = null
			$HPBar.visible = false
			$Items.visible = false
			$Intention.visible = false
			SignalBus.slave_ran.emit(self)
		
		
		Enemy.Intention.Type.SummonStars:
			var star1 = SlavePool.fetch("starry")
			var star2 = SlavePool.fetch("starry")
			
			team.cull_the_dead()
			team.add_slave(star1)
			team.add_slave(star2)
			
	
	held_enemy.intention.extra_effect.call()
			
	_on_end_turn()
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("idle")
	$Intention.visible = false
	SignalBus.new_turn.emit()

func add_buff(buff_name: String, turns: int):
	if buffs.has(buff_name):
		buffs[buff_name] += turns
	else: buffs.set(buff_name, turns)
	
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
		SignalBus.slave_info.emit(held)

func _on_clickable_area_button_down() -> void:
	SignalBus.slave_selected.emit(self)



func _on_end_turn() -> void:
	turn_ended.emit()
	toggle_arrow(false)
	
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")
	



# only if evil
func _decide_intentions() -> void:
	if not held.is_alive: return
	
	$Intention.visible = true
	var held_enemy : Enemy = held
	held_enemy.decide_intention(self)
	
	var total = held_enemy.intention.amount
	if held_enemy.intention.type == Enemy.Intention.Type.DamageSingular\
		or held_enemy.intention.type == Enemy.Intention.Type.DamageMultiple:
		total += power
	
	if total == 0: $Intention/Label.text = ""
	else: $Intention/Label.text = str(total)
	
	var icon: Texture2D 
	
	match(held_enemy.intention.type):
		Enemy.Intention.Type.DamageSingular: 
			icon = Gallery.icon_harm_single
		Enemy.Intention.Type.DamageTwo: 
			icon = Gallery.icon_harm_two
		Enemy.Intention.Type.DamageMultiple:
			icon = Gallery.icon_harm_multiple
		Enemy.Intention.Type.HealSingle:
			icon = Gallery.icon_heal_single
		Enemy.Intention.Type.HealMultiple:
			icon = Gallery.icon_heal_multiple
		Enemy.Intention.Type.PowerUp:
			icon = Gallery.icon_powerup
		Enemy.Intention.Type.Run:
			icon = Gallery.icon_run
		Enemy.Intention.Type.SummonStars:
			icon = Gallery.icon_summon_stars
	
	$Intention/TargetTop.visible = false
	$Intention/TargetMiddle.visible = false
	$Intention/TargetBottom.visible = false
	
	for target in [held_enemy.intention.target, held_enemy.intention.target_second]:
		match(target):
			Enemy.Intention.Target.Up: $Intention/TargetTop.visible = true
			Enemy.Intention.Target.Middle: $Intention/TargetMiddle.visible = true
			Enemy.Intention.Target.Bottom: $Intention/TargetBottom.visible = true
			Enemy.Intention.Target.All:
				$Intention/TargetTop.visible = true
				$Intention/TargetMiddle.visible = true
				$Intention/TargetBottom.visible = true
	
	
	$Intention/Icon.texture = icon
