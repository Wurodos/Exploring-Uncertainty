extends Node

# ====================
# Common
# ====================

signal locale_changed
signal exit_game

# Stops existing music, plays new
signal play_music(track: String)

signal stop_music

# Doesn't stop other sounds
signal play_sound(track: String)

# ====================
# POPUPS
# ====================

signal advance_tutorial
signal lost_item(item: Item)

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
signal mouse_delta(delta: Vector2)
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

signal speed_queue_mouse_entered(slave: Slave)
signal speed_queue_mouse_exit(slave: Slave)

signal slave_info(slave: Slave)

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

# for triggers
signal entered_room(room: Room)

signal battle_encounter

signal found_item
signal enter_city(city: Room)
signal enter_govnov
signal enter_comms(comms: Room)
signal change_steps(delta: int)
signal city_heal
signal govnov_heal
