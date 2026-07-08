extends Reptile

@export var vignette: PackedScene = null
@export var dlg_darkness: DialogueNode = null

@export var timer_turns: int = 3
@export var timer_damage: int = 10
@export var timer_increase: int = 10

var old_radius: int = 2
var current_vignette: Node = null

func _init() -> void:
	super._init()
	is_final_boss = true

func connect_events() -> void:
	super.connect_events()
	SignalBus.start_battle.connect(func(): on_start_any_battle.call_deferred())

# Map

func on_player_moved() -> void:
	super.on_player_moved()
	if Map.dist(Map.instance.party_room(), room) < 5:
		old_radius = CurrentRun.explore_radius
		CurrentRun.explore_radius = 1
		if not current_vignette:
			current_vignette = vignette.instantiate()
			Game.instance.add_child(current_vignette)
		
		if dlg_darkness:
			SignalBus.new_message.emit(dlg_darkness)
			dlg_darkness = null
	else: 
		CurrentRun.explore_radius = old_radius
		if current_vignette:
			current_vignette.queue_free()



# Battle
func on_start_any_battle() -> void:
	if Map.dist(Map.instance.party_room(), room) < 5:
		for slave in Battle.instance.good_team.boys_nodes:
			slave.add_buff(Action.DARK, 1)
			
func on_start_battle(node: SlaveNode) -> void:
	super.on_start_battle(node)
	node.get_node("ClickableArea").position += Vector2(100,0)
	node.get_node("ClickableArea").scale = Vector2(3,3)
	
	if not current_vignette:
		current_vignette = vignette.instantiate()
		Game.instance.add_child(current_vignette)
	for slave in Battle.instance.good_team.boys_nodes:
		slave.add_buff(Action.DARK, 3)

func multiply_received_damage(source: SlaveNode, harm: int) -> int:
	if source.buffs.has(Action.DARK): return 0
	else: return harm


# Round 1: Summon TRACTOR
# Round 2: Summon 2 JETS
# Round 3+: 
#	1) No darkness on any fighter: apply Darkness 3 turns
#	2) 1-2 allies alive, once per battle: summon TRUMAN
#	3) Weakest target: timer 3, 10 damage, +10 damage for each darkness, apply darkness 3 turns

var truman_summoned: bool = false

func _on_received_damage(source: SlaveNode, dmg: int) -> void:
	if intention.timer > 0:
		intention.timer_damage_remain -= dmg
		if intention.timer_damage_remain <= 0:
			intention.timer += 1
			intention.timer_damage_max += timer_increase
			intention.timer_damage_remain = intention.timer_damage_max
		owner.update_intention()

func decide_intention() -> void:
	super.decide_intention()

	if Battle.instance.round == 1:
		intention.type = Intention.Type.Reinforcement
		intention.amount = 1
		intention.extra_data = "tractor"
		intention.is_support = true
	elif Battle.instance.round == 2:
		intention.type = Intention.Type.Reinforcement
		intention.amount = 2
		intention.extra_data = "jet"
		intention.is_support = true
	else:
		for dude: SlaveNode in Battle.instance.good_team.boys_nodes:
			if not dude.buffs.has(Action.DARK):
				intention.type = Intention.Type.DamageMultiple
				intention.is_support = false
				intention.is_melee = false
				intention.effect = func(v: SlaveNode):
					v.add_buff(Action.DARK, 3)
				intention.targets = []
				for i in range(Battle.instance.good_team.boys_nodes.size()):
					intention.targets.append(i)
				return
		
		if not truman_summoned and CurrentRun.evil_boys.size() < 4:
			truman_summoned = true
			intention.type = Intention.Type.Reinforcement
			intention.amount = 1
			intention.extra_data = "truman"
			intention.is_support = true
			return

		var target = _get_target(func(slave: SlaveNode):
			if not slave.held.is_alive:
				return -INF 
			return -slave.held.hp
		)
		var victim = Battle.instance.good_team.boys_nodes[target]
		var displayed = 10
		if victim.buffs.has(Action.DARK): displayed *= victim.buffs[Action.DARK] + 1
		
		intention.timer = timer_turns
		intention.timer_damage_max = timer_damage
		intention.timer_damage_remain = timer_damage
		intention.type = Intention.Type.DamageSingular
		intention.is_support = false
		intention.is_melee = false
		intention.amount = Action.calculate_damage(owner, victim, displayed)
		intention.effect = func(v: SlaveNode):
			var dmg = 10
			if victim.buffs.has(Action.DARK): dmg *= victim.buffs[Action.DARK] + 1
			Action.deal_damage(owner, v, dmg)
			v.add_buff(Action.DARK, 3)
		intention.targets = [target]
		

#
