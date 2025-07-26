extends Item

var sender: SlaveNode
var _proc_once : bool = false

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.hp_changed.connect(_on_hp_changed)
	sender = owner

func _on_hp_changed():
	if not _proc_once and sender.held.hp * 2 <= sender.held.maxhp:
		_proc_once = true
		Action.heal(sender, sender, sender.held.maxhp / 2)
		sender.remove_item(u_name)
		
