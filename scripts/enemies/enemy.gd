extends Slave

class_name Enemy

class Intention:
	enum Type { DamageSingular, DamageMultiple, DamageTwo,
	 PowerUp, HealSingle, HealMultiple, Run, SummonStars }
	enum Target { Middle, Bottom, Up, All, Two, None }
		
	var type: Type
	var amount: int
	var target: Target
	var target_second: Target
	var extra_effect: Callable
	
	func _init(type: Type, amount: int = 0) -> void:
		self.type = type
		self.target = Target.None
		self.target_second = Target.None
		self.amount = amount
		self.extra_effect = func() : return
	
@export var info_count: int = 0
@export_multiline var info_1 : String
@export_multiline var info_2 : String
@export_multiline var info_3 : String
@export_multiline var info_4 : String

var info: Array[String] = []
var intention: Intention
var is_final_boss: bool = false

func _init() -> void:
	super._init()
	is_evil = true
	info = []

func localize() -> void:
	super.localize()
	info = []
	for i in range(info_count):
		info.append(tr(u_name + "_info_" + str(i)))

func get_all_info() -> Array[String]:
	return [info_1, info_2, info_3, info_4]

# Override this
func update_stats(node: SlaveNode) -> void:
	pass

# Override this	
func decide_intention(node: SlaveNode) -> void:
	pass

func _get_random_good_target() -> int:
	var possible : Array[int] = []
	var i = 0
	for slave : Slave in CurrentRun.good_boys:
		if slave.is_alive:
			possible.append(i)
		i += 1	
	return possible.pick_random()

func _get_good_target(score_func: Callable):
	pass

func _get_random_evil_target(is_self_included: bool = true) -> int:
	var possible : Array[int] = []
	var i = 0
	for slave : Slave in CurrentRun.evil_boys:
		if is_self_included and slave == self:
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
	return -1
