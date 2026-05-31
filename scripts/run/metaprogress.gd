extends Node

const save_path = "user://metaprogress.save"

# ===========  PACKS  ============

var packs: Array[String] = [
	"field_kitchen",
	"young_patriot"
]

# ===========  RUNS INFO  ============
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
	packs = [
		"field_kitchen",
		"young_patriot"
	]
	get_tree().quit()

func save_progress() -> void:
	var save_file : FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	var save_data = {
		"tutorial": completed_tutorial,
		"runs": runs_completed,
		"packs": packs
	}
	
	save_file.store_line(JSON.stringify(save_data))

func unlock_pack(pack_id: String) -> void:
	if not CurrentRun.is_tutorial and not CurrentRun.is_debug:
		if not packs.has(pack_id):
			packs.append(pack_id)

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
		
		if data.has("tutorial"):
			completed_tutorial = data["tutorial"]
		if data.has("runs"):
			runs_completed = data["runs"]
		if data.has("packs"):
			packs.assign(data["packs"])
		
		
