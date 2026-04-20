extends Node

const save_path = "user://metaprogress.save"

#

var runs_completed: int = 0


# ===========  FLAGS  ============

var completed_tutorial: bool = false


# =================================

func _ready() -> void:
	if FileAccess.file_exists(save_path):
		load_progress()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_progress()

func _exit_tree() -> void:
	save_progress()

func reset_progress() -> void:
	completed_tutorial = false
	runs_completed = 0
	get_tree().quit()

func save_progress() -> void:
	var save_file : FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	var save_data = {
		"tutorial": completed_tutorial,
		"runs": runs_completed
	}
	
	save_file.store_line(JSON.stringify(save_data))

func load_progress() -> void:
	var save_file : FileAccess = FileAccess.open(save_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON PARSE ERROR: ", json.get_error_message())
			continue
		
		var data = json.data
		
		completed_tutorial = data["tutorial"]
		runs_completed = data["runs"]
		
		
