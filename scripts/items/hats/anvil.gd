extends Item

@export var required_harm: int = 3
@export var power_gain: int = 1

var total_received : int = 0
var user: SlaveNode

func localize():
	super.localize()
	desc = desc.format([required_harm, power_gain], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	owner.received_damage.connect(_on_received_damage)
	total_received = 0
	user = owner

func use_item(sender: SlaveNode, ally: SlaveNode):
	super.use_item(sender, ally)
	var half : int = sender.power / 2 + sender.power % 2
	sender.set_power(-half)
	ally.set_power(+half)

func _on_received_damage(_source: SlaveNode, dmg: int):
	total_received += dmg
	user.set_power(+power_gain*(total_received / required_harm))
	total_received %= required_harm

func on_level_up():
	extra_hp += 3
	match(level):
		2: extra_hp += 4
		3: power_gain += 1
		4: extra_hp += 6
		5: required_harm -= 1
	super.on_level_up()

func get_priority(sender: SlaveNode, ally: SlaveNode) -> int:
	if sender == ally: return -999
	if sender.power < 3: return -3
	if ally.held.hp > sender.held.hp:
		return round(float(ally.held.hp) / sender.held.hp)
	return 0

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.PowerUp, sender.power / 2 + sender.power % 2)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
