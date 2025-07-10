extends Node

# ====================
# Change scene
# ====================

signal start_battle

# ====================
# Input
# ====================

signal mouse_up
signal mouse_dragged(pos: Vector2)
signal mouse_right_down
signal mouse_right_up

# ====================
# Battle sequencing
# ====================

signal new_round
signal new_turn

signal action_ended

signal slave_selected(slave: SlaveNode)
signal slave_mouse_entered(slave: SlaveNode)
signal slave_mouse_exited(slave: SlaveNode)

signal slave_info(slave: SlaveNode)

signal slave_death(slave: SlaveNode)

signal evil_won
signal good_won

# ====================
# Item actions
# ====================
