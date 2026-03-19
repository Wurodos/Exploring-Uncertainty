extends Node

func close() -> void:
	queue_free()

func replace_room(type: Room.Type):
	var row := Map.instance.encounter_room.row
	var col := Map.instance.encounter_room.col
	Map.instance.encounter_room.free()
	Map.instance.add_room(row, col, type)

func _on_elevator_pressed() -> void:
	replace_room(Room.Type.Elevator)
	close()


func _on_city_pressed() -> void:
	replace_room(Room.Type.City)
	close()


func _on_comms_pressed() -> void:
	replace_room(Room.Type.Comms)
	close()
