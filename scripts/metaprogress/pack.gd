extends Resource
class_name Pack

@export var u_name: String = ""
@export var items: Array[Item] = []

func check_unlocked() -> bool:
	return Metaprogress.packs.has(u_name)

func on_start_run() -> void:
	pass
