extends Node

const APPETITE = "appetite"
const SHIELD = "shield"
const BLASPHEMY = "blasphemy"
const FREEZE = "freeze"
const DARK = "dark"

func deal_damage(sender: SlaveNode, victim: SlaveNode, dmg: int, dont_proc: bool = false):
	SignalBus.play_sound.emit("hurt")
	
	var total_dmg = dmg
	
	total_dmg += sender.power
	
	var roll = randi_range(0, 99)
	var is_crit = roll < 4 * (sender.luck+1)
	
	if victim.buffs.has(SHIELD) and not is_crit:
		total_dmg = floor(total_dmg * 0.7)
	
	if sender.buffs.has(APPETITE):
		total_dmg += floor(total_dmg / 3)
	
	if victim.buffs.has(FREEZE):
		total_dmg += floor(total_dmg / 2)
	
	if is_crit:
		total_dmg *= 2
	
	if sender.buffs.has(BLASPHEMY):
		heal(sender, sender, floor(total_dmg*2/5))
	
	victim.set_hp(-total_dmg)
	
	if not dont_proc:
		victim.received_damage.emit(sender, total_dmg)
	
	if is_crit: victim.crit_animation.play("crit")
	victim.hit_animation.play("hit")
	#
	#await victim.animation_player.animation_finished
	#victim.animation_player.play("idle")

func heal(sender: SlaveNode, ally: SlaveNode, amount: int):
	SignalBus.play_sound.emit("heal")
	
	if not ally.held.is_alive: return
	
	ally.set_hp(min(ally.held.maxhp, ally.held.hp + amount), false)
	
	ally.heal_animation.play("heal")
	#await ally.animation_player.animation_finished
	#ally.animation_player.play("idle")
