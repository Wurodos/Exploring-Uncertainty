extends Control

@onready var recon_1 : Array[Node] = $PossibleTeam1.get_children()
@onready var recon_2 : Array[Node] = $PossibleTeam2.get_children()

func _ready() -> void:
	visible = false
	
func _update() -> void:
	var back: int = CurrentRun.evil_deck.size() - 1
	for i in range(3):
		(recon_1[i] as SlaveTeamNode).apply(CurrentRun.evil_deck[back - i], SlaveTeamNode.Type.OnlyItems)
		(recon_2[i] as SlaveTeamNode).apply(CurrentRun.evil_deck[back - i - 3], SlaveTeamNode.Type.OnlyItems)
		

func _on_show_recon_pressed() -> void:
	_update()
	visible = true
	CurrentRun.state = Game.State.Window
	


func _on_close_pressed() -> void:
	visible = false
	CurrentRun.state = Game.State.Map
