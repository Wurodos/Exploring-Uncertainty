extends Item

@export var heal: int = 8
var stored: Array[Item] = []

func localize():
	super.localize()
	desc = desc.format([heal], "{}")

func on_start_battle(owner: SlaveNode):
	super.on_start_battle(owner)
	if owner.held is Enemy: return
	stored = []
	owner.consumed.connect(_store)

func _store(item: Item) -> void:
	stored.append(item)

func on_end_battle(owner: Slave):
	super.on_end_battle(owner)
	for item in stored:
		CurrentRun.put_item_in_inventory(item)

func use_item(sender: SlaveNode, victim: SlaveNode):
	super.use_item(sender, victim)
	Action.heal(sender, victim, heal)

func on_level_up():
	super.on_level_up()
	extra_hp += 2
	heal += 2

func get_priority(_sender: SlaveNode, ally: SlaveNode) -> int:
	if not ally.held.is_alive:
		return -999
	if ally.held.hp < ally.held.maxhp / 2:
		return +1
	return 0

func get_intention(sender: SlaveNode) -> Enemy.Intention:
	var intention = Enemy.Intention.new(Enemy.Intention.Type.HealSingle, heal)
	intention.is_support = true
	intention.effect = func(v):
		use_item(sender, v)
	return intention
