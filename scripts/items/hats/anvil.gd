extends Item

var total_received : int = 0
var user: SlaveNode

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	total_received = 0
	user = sender
	sender.add_buff("anvil", 1)
	sender.received_damage.connect(_on_received_damage)

func _on_received_damage(_source: SlaveNode, dmg: int):
	if user.buffs.has("anvil"):
		total_received += dmg
		user.set_power(+1*(total_received / 3))
		total_received %= 3
