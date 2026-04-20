extends Slave

class_name Enemy

class Intention:
	enum Type { DamageSingular, DamageMultiple, DamageTwo,
	 PowerUp, HealSingle, HealMultiple, Run, SummonStars,
	 Reinforcement, OrderChervs, Support, None }
		
	var type: Type
	var amount: int = -1
	var targets: Array[int] = []
	var effect: Callable
	var is_support: bool = false
	var is_melee: bool = true
	var timer: int  = 0
	var extra_data: Variant
	
	@warning_ignore("shadowed_variable")
	func _init(type: Type, amount: int = -1) -> void:
		self.type = type
		self.amount = amount
		self.effect = func(_victim) : return
	
@export var info_count: int = 0

var info_title: Array[String] = []
var info: Array[String] = []
var intention: Intention
var is_final_boss: bool = false

var owner: SlaveNode

func _init() -> void:
	super._init()
	intention = Intention.new(Intention.Type.None)
	is_evil = true
	info = []

func localize() -> void:
	super.localize()
	info = []
	for i in range(info_count):
		info_title.append(tr(u_name + "_title_" + str(i)))
		info.append(tr(u_name + "_info_" + str(i)))

static func deserialize(data: Dictionary) -> Enemy:
	var enemy : Enemy = SlavePool.fetch(data["u_name"])
	
	enemy.maxhp = data["maxhp"]
	enemy.hp = data["hp"]
	
	enemy.weapon = Item.deserialize(data["weapon"])
	enemy.hat = Item.deserialize(data["hat"])
	enemy.trinket1 = Item.deserialize(data["trinket1"])
	enemy.trinket2 = Item.deserialize(data["trinket2"])
	
	return enemy

func on_attacked(_attacker: SlaveNode) -> void:
	if not owner.tags.has(Action.TAG_WAS_ATTACKED_THIS_ROUND):
		owner.tags.append(Action.TAG_WAS_ATTACKED_THIS_ROUND)

# Override this
func update_stats(node: SlaveNode) -> void:
	owner = node
	
func decide_intention() -> void:
	intention = Intention.new(Intention.Type.None)
	intention.targets = []
	intention.is_support = false

func _intention_run() -> void:
	intention = Intention.new(Intention.Type.Run)
	intention.is_support = true

func _intention_weapon(target: int, victim: SlaveNode) -> void:
	intention = owner.held.weapon.get_intention(owner)
	intention.amount = owner.held.weapon.get_displayed_harm(owner, victim)
	intention.is_melee = owner.held.weapon.is_melee
	if intention.targets.is_empty():
		intention.targets = [target]


# condition returns a number
# highest gets picked
func _get_target(condition: Callable) -> int:
	var i := 0
	var id := 0
	var highest := -INF
	for slave : SlaveNode in Battle.instance.good_team.boys_nodes:
		if (condition.call(slave) as int) > highest:
			id = i
			highest = condition.call(slave)
		i += 1
	return id

func _get_random_good_target() -> int:
	var possible : Array[int] = []
	var i = 0
	var only_normal_priority: bool = false
	
	for slave : SlaveNode in Battle.instance.good_team.boys_nodes:
		if slave.held.is_alive and slave.tags.has(Action.TAG_HIGH_PRIORITY):
			possible.append(i)
		i += 1
	if not possible.is_empty():
		return possible.pick_random()
	
	for slave : SlaveNode in Battle.instance.good_team.boys_nodes:
		if slave.held.is_alive and not slave.tags.has(Action.TAG_LOW_PRIORITY):
			only_normal_priority = true
			break
	
	i = 0
	for slave : SlaveNode in Battle.instance.good_team.boys_nodes:
		if slave.held.is_alive and (not only_normal_priority or not slave.tags.has(Action.TAG_LOW_PRIORITY)):
			possible.append(i)
		i += 1	
	return possible.pick_random()

func _convert_node_to_target(node: SlaveNode, team: Array[Slave]) -> int:
	var i = 0
	for slave : Slave in team:
		if slave == node.held:
			return i
		i += 1
	
	return 0

func _get_random_evil_target(is_self_included: bool = true) -> int:
	var possible : Array[int] = []
	var i = 0
	for slave : Slave in CurrentRun.evil_boys:
		if not is_self_included and slave == self:
			i += 1
			continue
		if slave.is_alive:
			possible.append(i)
		i += 1	
	return possible.pick_random()

func _get_self_target() -> int:
	var i = 0
	for slave : Slave in CurrentRun.evil_boys:
		if slave == self:
			return i 
		i += 1
	return 0
