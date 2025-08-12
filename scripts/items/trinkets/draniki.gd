extends Item

@export var hp_threshold_percent: int = 50
@export var hp_heal_percent: int = 50

var sender: SlaveNode
var _proc_once : bool = false

func localize():
	super.localize()
	desc = desc.format([hp_threshold_percent, hp_heal_percent], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.hp_changed.connect(_on_hp_changed)
	sender = owner

func _on_hp_changed():
	if not _proc_once and sender.held.hp * (100.0 / hp_threshold_percent) <= sender.held.maxhp:
		_proc_once = true
		Action.heal(sender, sender, sender.held.maxhp / (100.0 / hp_heal_percent))
		sender.remove_item(u_name)
		
