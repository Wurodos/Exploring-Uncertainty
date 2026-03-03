extends Control

@onready var recon_1 : Array[Node] = $PossibleTeam1.get_children()
@onready var recon_2 : Array[Node] = $PossibleTeam2.get_children()

func _ready() -> void:
	visible = false
	
func _update() -> void:
	pass
		

func _on_show_recon_pressed() -> void:
	_update()
	visible = true
	CurrentRun.state = Game.State.Window
	


func _on_close_pressed() -> void:
	visible = false
	CurrentRun.state = Game.State.Map
