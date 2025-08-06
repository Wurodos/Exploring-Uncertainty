extends Node

# ====================
# Change scene
# ====================

signal start_battle
signal end_encounter

signal refresh

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
signal slave_ran(slave: SlaveNode)

signal evil_won
signal good_won

signal end_battle

# ====================
# Team Window
# ====================

signal add_item(item: Item)
signal show_item_info(item: Item)
signal hide_item_info

# ====================
# Room encounters
# ====================

signal battle_encounter
signal enter_city(city: Room)
signal enter_govnov
signal city_heal
signal govnov_heal
