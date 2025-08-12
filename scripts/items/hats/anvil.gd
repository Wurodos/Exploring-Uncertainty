extends Item

@export var required_harm: int = 3
@export var power_gain: int = 1
@export var turns: int = 3

var total_received : int = 0
var user: SlaveNode

func localize():
	super.localize()
	desc = desc.format([required_harm, power_gain, turns], "{}")

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	total_received = 0
	user = sender
	sender.add_buff("anvil", turns)
	sender.received_damage.connect(_on_received_damage)

func _on_received_damage(_source: SlaveNode, dmg: int):
	if user.buffs.has("anvil"):
		total_received += dmg
		user.set_power(+power_gain*(total_received / required_harm))
		total_received %= required_harm
