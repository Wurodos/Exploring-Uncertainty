extends Slave

class_name Enemy

class Intention:
	enum Type { DamageSingular }
	enum Target { Middle, Bottom, Up }
		
	var type: Type
	var amount: int
	var target: Target
	
	func _init(type: Type, amount: int) -> void:
		self.type = type
		self.amount = amount
	

@export_multiline var info_1 : String
@export_multiline var info_2 : String
@export_multiline var info_3 : String
@export_multiline var info_4 : String

var intention: Intention

func _init() -> void:
	super._init()
	is_evil = true

func get_all_info() -> Array[String]:
	return [info_1, info_2, info_3, info_4]

# Override this	
func decide_intention() -> void:
	pass
