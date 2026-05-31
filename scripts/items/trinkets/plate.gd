extends Item

@export var heal_give_receive: int = 1

var sender: Slave

func localize():
	super.localize()
	desc = desc.format([heal_give_receive], "{}")

func on_equip(owner: Slave):
	super.on_equip(owner)
	sender = owner
	owner.heal_give += heal_give_receive
	owner.heal_receive += heal_give_receive

func on_unequip(owner: Slave):
	super.on_unequip(owner)
	owner.heal_give -= heal_give_receive
	owner.heal_receive -= heal_give_receive

func on_level_up():
	super.on_level_up()
	if sender:
		sender.heal_give += 1
		sender.heal_receive += 1
	heal_give_receive += 1
