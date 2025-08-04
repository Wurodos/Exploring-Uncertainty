extends Node

var _pool : Dictionary[StringName, Slave]

func _ready() -> void:
	var dir_access : DirAccess = DirAccess.open("res://pool/reptiles")
	var files : PackedStringArray = dir_access.get_files()
	
	for file_name : String in files:
		var loaded : Slave = load("res://pool/reptiles/" + file_name)
		loaded.reinit()
		_pool[loaded.u_name] = loaded
		print("REPTILE_POOL: Loaded " + loaded.u_name + " successfully")

func fetch(slave_name: StringName) -> Slave:
	var new_slave: Slave = _pool[slave_name].duplicate()
	new_slave.reinit()
	return new_slave
