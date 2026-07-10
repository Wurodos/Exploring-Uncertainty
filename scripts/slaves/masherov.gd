extends Slave

var ready_to_run: bool = false

func on_start_battle(_node: SlaveNode) -> void:
	super.on_start_battle(_node)
	ready_to_run = false

func on_start_turn(node: SlaveNode) -> void:
	super.on_start_turn(node)
	if ready_to_run:
		node.death()
		node.visible = false
		SignalBus.slave_ran.emit(node)

# Attempt to run when hp <= 50%
func on_hp_changed() -> void:
	super.on_hp_changed()
	if not Battle.instance: return
	if hp <= 0 or ready_to_run or hp * 2 > maxhp: return
	
	ready_to_run = true
	var slave_node: SlaveNode = Battle.instance.find_slave_node(self)
	slave_node.get_node("Intention").visible = true
	slave_node.get_node("Intention").get_child(0).texture = Gallery.icon_run
