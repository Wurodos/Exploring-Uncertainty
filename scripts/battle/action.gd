extends Node

const SHIELD = "shield"
const BLASPHEMY = "blasphemy"

func deal_damage(sender: SlaveNode, victim: SlaveNode, dmg: int):
	var total_dmg = dmg
	
	total_dmg += sender.power
	
	var roll = randi_range(0, 99)
	var is_crit = roll < 4 * (sender.luck+1)
	
	if victim.buffs.has(SHIELD) and not is_crit:
		total_dmg /= 2
	
	if sender.buffs.has(BLASPHEMY):
		heal(sender, sender, total_dmg*2/5)
	
	if is_crit:
		print("Critical hit! " + str(roll))
		total_dmg *= 2
	
	victim.set_hp(-total_dmg)
	victim.received_damage.emit(sender, total_dmg)

func heal(sender: SlaveNode, ally: SlaveNode, amount: int):
	if not ally.held.is_alive: return
	
	ally.set_hp(min(ally.held.maxhp, ally.held.hp + amount), false)
