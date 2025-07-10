extends Node

const SHIELD = "shield"
const BLASPHEMY = "blasphemy"

func deal_damage(sender: SlaveNode, victim: SlaveNode, dmg: int):
	var total_dmg = dmg
	
	total_dmg += sender.power
	
	if victim.buffs.has(SHIELD):
		total_dmg /= 2
	victim.set_hp(-total_dmg)
	
	if sender.buffs.has(BLASPHEMY):
		heal(sender, sender, total_dmg*2/5)
	
	victim.received_damage.emit(sender, total_dmg)

func heal(sender: SlaveNode, ally: SlaveNode, amount: int):
	ally.set_hp(min(ally.held.maxhp, ally.held.hp + amount), false)
