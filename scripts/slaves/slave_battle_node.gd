extends Node2D

class_name SlaveNode

@export var hit_animation: AnimationPlayer
@export var heal_animation: AnimationPlayer
@export var powerup_animation: AnimationPlayer
@export var label_animation: AnimationPlayer

signal received_damage(source: SlaveNode, dmg: int)
signal hp_changed
signal turn_ended
signal turn_started
signal consumed
signal attacked(victim: SlaveNode)

@onready var line_start: Vector2 = $CircleSelect/LineStart.global_position
@onready var line_end: Vector2 = $CircleSelect/LineEnd.global_position
@onready var ellipse: Sprite2D = $CircleSelect
@onready var stat_parent: Control = $Stats

@onready var arrow: Sprite2D = $Arrow
@onready var arrow_animation: AnimationPlayer = $ArrowAnimation

const item_prefab = preload("res://prefabs/items/item.tscn")
const stat_entry_prefab = preload("res://prefabs/battle/stat_entry.tscn")

var is_mouse_over: bool = false
var follow_rope: Node2D = null

var held: Slave
var sprite: Sprite2D
var team: Team

var weapon_node: ItemNode
var hat_node: ItemNode
var trinket1_node: ItemNode
var trinket2_node: ItemNode
var trinket3_node: ItemNode

# name -> turns left
var buffs : Dictionary[String, int] = {}
# tags are simillar to buffs, but dont have a timer
var tags: Array[String] = []

var power : int = 0
var luck : int = 0
var static_stat: int = 0

var vigilance: bool = false:
	set(val):
		vigilance = val
		%Vigilance.visible = val
var viable_for_vigilance: bool = false

var item_parent : Node2D

func _ready() -> void:
	SignalBus.mouse_up.connect(_on_mouse_up)
	SignalBus.mouse_right_down.connect(_on_mouse_right_down)
	if held is Enemy:
		SignalBus.new_round.connect(_decide_intentions)
	set_hp(0)

func _process(_delta: float) -> void:
	if follow_rope:
		global_position = follow_rope.global_position

func toggle_arrow(on: bool) -> void:
	if on:
		$Arrow.visible = true
		$ArrowAnimation.play("bounce")
	else:
		$Arrow.visible = false
		$ArrowAnimation.play("RESET")

func reapply() -> void:
	apply(held, held.is_evil)

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
					elif tr_id == 2: trinket2_node.apply(held.trinket2)
					elif tr_id == 3: trinket3_node.apply(held.trinket3)
			return	

func set_max_hp(new_val: int, is_delta: bool = true):
	if is_delta: held.maxhp += new_val
	else: held.maxhp = new_val
	
	%HPBar.value = (held.hp/float(held.maxhp)*100)

func set_hp(new_val: int, is_delta: bool = true):
	if is_delta: held.hp += new_val
	else: held.hp = new_val
	
	%HPBar.value = (held.hp/float(held.maxhp)*100)
	
	# Death
	if held.hp <= 0 and held.is_alive:
		death()
	else: hp_changed.emit()

func death(undeath: bool = false) -> void:
	held.is_alive = undeath
	sprite.texture = Gallery.img_dead_slave
	%HPBar.visible = undeath
	item_parent.visible = undeath
	$Intention.visible = undeath
	arrow.visible = undeath
	
	if undeath:
		reapply()
		SignalBus.slave_undeath.emit(self)
	else:
		SignalBus.slave_death.emit(self)

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
		powerup_animation.play("powerup")
	add_stat("power", Gallery.icon_power, power)

func set_luck(new_val: int, is_delta: bool = true):
	if is_delta:
		luck += new_val
	else: luck = new_val
	
	add_stat("luck", Gallery.icon_luck, luck)

func set_static(new_val: int, is_delta: bool = true):
	var old_val: int = static_stat
	
	if is_delta:
		static_stat += new_val
	else: static_stat = new_val
	
	if static_stat > old_val:
		pass
		#SignalBus.play_sound.emit("powerup")
		#powerup_animation.play("powerup")
	add_stat("static", Gallery.icon_static, static_stat)
			
func apply(slave: Slave, is_evil: bool = false) -> void:
	held = slave
	visible = true
	if held is Reptile:
		%HPBar.visible = false
		%Stats.visible = false
	
	if held.unique_visual and $Parts/Visual.visible:
		$Parts/Visual.visible = false
		$Parts.add_child(held.unique_visual.instantiate())
		return
	
	match(held.sprite_size):
		Slave.SpriteSize.Normal:
			$Parts.scale = Vector2(1, 1)
			item_parent = $Parts/Visual/Items
		Slave.SpriteSize.Big:
			$Parts.scale = Vector2(1.5, 1.5)
			item_parent = $Parts/Visual/BigItems
		Slave.SpriteSize.TwoHead:
			$Parts.scale = Vector2(1, 1)
			item_parent = $Parts/Visual/TwoHeads
	
	sprite = $Parts/Visual/Sprite
	sprite.texture = slave.texture
	
	if is_evil:
		#sprite.flip_h = true
		$Parts.scale.x *= -1
		$AnimationSprites.scale = Vector2(-1, 1)
		#for offset_node: Node2D in item_parent.get_children():
		#	offset_node.position.x *= -1
		
	if weapon_node == null:
		weapon_node = item_prefab.instantiate()
		item_parent.get_node("Weapon").add_child(weapon_node)
	weapon_node.apply(held.weapon)
	
	if hat_node == null:
		hat_node = item_prefab.instantiate()
		item_parent.get_node("Hat").add_child(hat_node)
	hat_node.apply(held.hat)
	
	if trinket1_node == null:
		trinket1_node = item_prefab.instantiate()
		item_parent.get_node("Trinket1").add_child(trinket1_node)
	trinket1_node.apply(held.trinket1)
	
	if trinket2_node == null:
		trinket2_node = item_prefab.instantiate()
		item_parent.get_node("Trinket2").add_child(trinket2_node)
	trinket2_node.apply(held.trinket2)
	
	if trinket3_node == null:
		trinket3_node = item_prefab.instantiate()
		item_parent.get_node("Trinket3").add_child(trinket3_node)
	trinket3_node.apply(held.trinket3)
	
	var extra_item = held.get_extra_item()
	if extra_item:
		var extra_node = item_prefab.instantiate()
		item_parent.get_node("Extra").add_child(extra_node)
		extra_node.apply(extra_item)

func add_stat(stat_name: String, icon: Texture2D, value: int):
	var stat_entry : StatEntry = stat_parent.find_child(stat_name, false, false)
	if stat_entry == null:
		stat_entry = stat_entry_prefab.instantiate()
		stat_entry.texture = icon
		stat_entry.name = stat_name
		stat_entry.init()
		stat_parent.add_child(stat_entry)
	
	stat_entry.visible = value != 0 or stat_name == "speed"
	stat_entry.label.text = str(value)
		

func start_battle() -> void:
	held.on_start_battle(self)
	if team.is_evil:
		var enemy: Enemy = held
		enemy.update_stats(self)
	for item : Item in held.get_all_items():
		item.on_start_battle(self)
	
	
func get_all_items() -> Array[Item]:
	return held.get_all_items()

func toggle_ellipse(visible: bool):
	$CircleSelect.visible = visible

func attack(victim: SlaveNode):
	#$AnimationPlayer.play("jump")
	var old_pos := global_position
	toggle_arrow(false)
	if held.weapon.is_melee:
		var tween = move_to(victim.get_node("Parts/Front").global_position)
		await tween.finished
	
	if buffs.has(Action.STUN):
		_on_end_turn.call_deferred()
		return
		
	if not (vigilance and tags.has(Action.TAG_VIGILANCE_KEEP_ATTACK)):
		viable_for_vigilance = false
	match(held.weapon.target):
		Item.Target.Single: 
			held.weapon.use_item(self, victim)
			if victim:
				if victim.held.is_alive:
					(victim.held as Enemy).on_attacked(self)
				attacked.emit(victim)
		Item.Target.AllTeam: 
			for slave in Battle.instance.evil_team.boys_nodes:
				held.weapon.use_item(self, slave)
				if slave:
					if slave.held.is_alive:
						(slave.held as Enemy).on_attacked(self)
					attacked.emit(slave)
	if held.weapon.is_melee:
		var tween = move_to(old_pos)
		await tween.finished
	_on_end_turn.call_deferred()
	
func support(ally: SlaveNode):
	#$AnimationPlayer.play("jump")
	toggle_arrow(false)
	if buffs.has(Action.STUN):
		_on_end_turn.call_deferred()
		return
	
	match(held.hat.target):
		Item.Target.Self:
			held.hat.use_item(self, self)
		Item.Target.Single: 
			held.hat.use_item(self, ally)
		Item.Target.AllTeam: 
			for slave in Battle.instance.good_team.boys_nodes:
				held.hat.use_item(self, slave)
	_on_end_turn.call_deferred()

func move_to(to: Vector2) -> Tween:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", to, 0.4).set_trans(Tween.TRANS_QUAD)
	tween.play()
	return tween

func start_turn() -> void:
	if not held is Enemy: toggle_arrow(true)
	turn_started.emit()

func ticker_down_buffs() -> void:
	tags.erase(Action.TAG_WAS_ATTACKED_THIS_ROUND)
	
	var to_be_erased : Array[String] = []
	for key: String in buffs.keys():
		buffs[key] -= 1
		add_stat(key, Gallery.icon_status[key], buffs[key])
		if buffs[key] == 0: to_be_erased.append(key)
	
	for key in to_be_erased:
		remove_buff(key)

func remove_buff(buff_name: String):
	var visual : Node2D = $Buffs.find_child(buff_name)
	if visual: visual.visible = false
	
	if buffs.has(buff_name) and Gallery.icon_status.has(buff_name):
		add_stat(buff_name, Gallery.icon_status[buff_name], 0)
	buffs.erase(buff_name)
	

func execute_intention():
	var held_enemy : Enemy = held
	var hide_intention := true
	
	await get_tree().create_timer(0.3).timeout
	
	if buffs.has(Action.STUN):
		pass
	elif held_enemy.intention.timer > 0:
		held_enemy.intention.timer -= 1
		update_intention()
		hide_intention = false
	elif not held_enemy.intention.is_support:
		if not tags.has(Action.TAG_VIGILANCE_KEEP_ATTACK):
			viable_for_vigilance = false
		
		var old_pos: Vector2 = global_position
		
		if held_enemy.intention.is_melee:
			var victim: SlaveNode = Battle.instance.good_team.boys_nodes[held_enemy.intention.targets[0]]
			var tween = move_to(victim.get_node("Parts/Front").global_position)
			await tween.finished
		
		for target_id in held_enemy.intention.targets:
			var victim: SlaveNode = Battle.instance.good_team.boys_nodes[target_id]
			held_enemy.intention.effect.call(victim)
			if not victim.tags.has(Action.TAG_WAS_ATTACKED_THIS_ROUND):
				victim.tags.append(Action.TAG_WAS_ATTACKED_THIS_ROUND)
			attacked.emit(victim)
		
		if held_enemy.intention.is_melee:
			var tween = move_to(old_pos)
			await tween.finished
	else:
		match(held_enemy.intention.type):
			Enemy.Intention.Type.Run:
				run()
			Enemy.Intention.Type.OrderChervs:
				for boy in team.boys_nodes:
					if boy.held is Cherv:
						if boy.get_node("Intention").visible:
							if (boy.held as Cherv).intention.is_support:
								(boy.held as Cherv).decide_weapon_intention()
							(boy.held as Cherv).intention.targets = [held_enemy.intention.targets[0]]
							(boy.held as Cherv).dont_change_target = true
						boy.set_power(+1)
						boy.update_intention()
			Enemy.Intention.Type.Reinforcement:
				for i in range(held_enemy.intention.amount):
					SignalBus.reinforcement.emit(self, held_enemy.intention.extra_data as String)
					if not is_instance_valid(self): 
						SignalBus.new_turn.emit()
						return
			_:
				for target_id in held_enemy.intention.targets:
					var victim: SlaveNode = Battle.instance.evil_team.boys_nodes[target_id]
					held_enemy.intention.effect.call(victim)
	
	await get_tree().create_timer(0.3).timeout
	$Intention.visible = not hide_intention
	_on_end_turn()
	SignalBus.new_turn.emit()

func run() -> void:
	visible = false
	held.is_alive = false
	SignalBus.slave_ran.emit(self)

func add_buff(buff_name: String, turns: int):
	if buffs.has(buff_name):
		buffs[buff_name] += turns
	else: buffs.set(buff_name, turns)
	
	var visual : Node2D = $Buffs.find_child(buff_name)
	if visual:
		visual.visible = true
		add_stat(buff_name, Gallery.icon_status[buff_name], buffs[buff_name])

const label_popup = preload("res://prefabs/slaves/label_popup.tscn")

func push_label_popup(text: String) -> void:
	var popup = label_popup.instantiate()
	popup.apply(text)
	add_child(popup)


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
		if held is Enemy:
			SignalBus.enemy_info.emit(held as Enemy)
		else: SignalBus.slave_info.emit(held)

func _on_clickable_area_button_down() -> void:
	SignalBus.slave_selected.emit(self)



func _on_end_turn() -> void:
	turn_ended.emit()
	
	



# only if evil
func _decide_intentions() -> void:
	if not held.is_alive: return
	if not $Intention.visible:
		$Intention.visible = true
		var held_enemy : Enemy = held
		held_enemy.decide_intention()
		update_intention()
	

func update_intention() -> void:
	var held_enemy : Enemy = held
	var total = held_enemy.intention.amount
	
	if total <= 0: $Intention/Label.text = ""
	else: $Intention/Label.text = str(total)

	if held_enemy.intention.timer > 0:
		$Timer.visible = true
		$Timer/Label.text = str(held_enemy.intention.timer)
	else:
		$Timer.visible = false
	
	var icon: Texture2D 
	
	match(held_enemy.intention.type):
		Enemy.Intention.Type.DamageSingular: 
			icon = Gallery.icon_harm_single
		Enemy.Intention.Type.Support:
			icon = Gallery.icon_support
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
		Enemy.Intention.Type.OrderChervs:
			icon = Gallery.icon_order
		Enemy.Intention.Type.Reinforcement:
			icon = Gallery.icon_summon_cherv
	
	$Intention/TargetTop.visible = false
	$Intention/TargetMiddle.visible = false
	$Intention/TargetBottom.visible = false
	
	for target in held_enemy.intention.targets:
		match(target):
			0: $Intention/TargetMiddle.visible = true
			1: $Intention/TargetBottom.visible = true
			2: $Intention/TargetTop.visible = true
	
	
	$Intention/Icon.texture = icon
