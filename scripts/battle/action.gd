extends Node

var crit_multiplier: int = 2
var damage_multiplier: int = 1

const APPETITE = "appetite"
const SHIELD = "shield"
const BLASPHEMY = "blasphemy"
const FREEZE = "freeze"
const DARK = "dark"
const STUN = "stun"

const TAG_BETTER_SHIELD = "tag_better_shield"
const TAG_STATUS_DAMAGE = "tag_status_damage"
const TAG_VIGILANCE_KEEP_ATTACK = "tag_vigilance_keep_attack"
const TAG_LOW_PRIORITY = "tag_low_priority"
const TAG_HIGH_PRIORITY = "tag_high_priority"
const TAG_PERMANENT_STATIC = "tag_permanent_static"
const TAG_STATIC_HEALTH = "tag_static_health"

func calculate_damage(sender: SlaveNode, victim: SlaveNode, dmg: int, _dont_proc: bool = false) -> int:
	var total_dmg = dmg
	
	total_dmg += sender.power
	if sender.tags.has(TAG_STATUS_DAMAGE):
		for turns: int in sender.buffs.values():
			if turns > 0: total_dmg += turns 
	
	total_dmg *= damage_multiplier
	if sender.buffs.has(APPETITE):
		total_dmg = ceil(float(total_dmg) * 3. / 2.)
	if victim and victim.buffs.has(FREEZE):
		total_dmg = ceil(float(total_dmg) * 3. / 2.)
	if victim and victim.buffs.has(SHIELD):
		if victim.tags.has(TAG_BETTER_SHIELD):
			total_dmg = ceil(float(total_dmg) * 2. / 5.)
		else: total_dmg = ceil(float(total_dmg) * 7. / 10.)
	
	return total_dmg

func deal_damage(sender: SlaveNode, victim: SlaveNode, dmg: int, dont_proc: bool = false):
	SignalBus.play_sound.emit("hurt")
	
	var total_dmg = calculate_damage(sender, victim, dmg, dont_proc)
	
	var roll = randi_range(0, 99)
	var is_crit = sender.vigilance or roll < 4 * (sender.luck+1)
	
	if not sender.tags.has(TAG_VIGILANCE_KEEP_ATTACK):
		sender.vigilance = false
	
	if not is_crit and victim.vigilance:
		roll = randi_range(0,1)
		if roll == 1: total_dmg = 0
	victim.vigilance = false
	
	if is_crit:
		total_dmg *= crit_multiplier
		if victim.buffs.has(SHIELD): 
			if victim.tags.has(TAG_BETTER_SHIELD):
				total_dmg = total_dmg * 5 / 2
			else: total_dmg = total_dmg * 10 / 7
	
	if sender.buffs.has(BLASPHEMY):
		heal(sender, sender, floor(total_dmg*2/5))
	
	if victim.tags.has(TAG_STATIC_HEALTH):
		var absorbed : int = min(total_dmg, victim.static_stat)
		total_dmg -= absorbed
		victim.set_static(-absorbed)
		
	victim.set_hp(-total_dmg)
	if victim.held.is_alive and victim.static_stat > 0:
		sender.set_hp(-victim.static_stat)
		if not victim.tags.has(TAG_PERMANENT_STATIC):
			var half : int = ceil(float(victim.static_stat) / 2.0)
			victim.set_static(-half)
		
	
	
	if not dont_proc:
		victim.received_damage.emit(sender, total_dmg)
	
	if is_crit: victim.crit_animation.play("crit")
	victim.hit_animation.play("hit")
	victim.viable_for_vigilance = false
	#
	#await victim.animation_player.animation_finished
	#victim.animation_player.play("idle")

func execute(sender: SlaveNode, victim: SlaveNode) -> void:
	SignalBus.play_sound.emit("hurt")
	if not sender.tags.has(TAG_VIGILANCE_KEEP_ATTACK):
		sender.vigilance = false
	victim.set_hp(0, false)
	victim.hit_animation.play("hit")
	victim.viable_for_vigilance = false

func heal(_sender: SlaveNode, ally: SlaveNode, amount: int):
	SignalBus.play_sound.emit("heal")
	
	if not ally.held.is_alive: return
	
	ally.set_hp(min(ally.held.maxhp, ally.held.hp + amount), false)
	
	ally.heal_animation.play("heal")
	#await ally.animation_player.animation_finished
	#ally.animation_player.play("idle")
