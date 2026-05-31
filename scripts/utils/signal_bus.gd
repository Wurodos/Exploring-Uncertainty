extends Node
@warning_ignore_start("unused_signal")

signal exit_the_mines

# ====================
# Common
# ====================

signal focus_camera(pos: Vector2)

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

signal advance_tutorial(specific_id: StringName)
signal lost_item(item: Item)
signal message_popup(string_id: StringName)
signal regime_change

# ====================
# Change scene
# ====================

signal start_battle(wave_count: int)
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
# Draft Pack
# ====================

signal pick_pack(pack: Pack)

# ====================
# Dialogue
# ====================

signal new_message(id: String)

# ====================
# Battle sequencing
# ====================

signal new_round
signal new_turn
signal did_action

signal action_ended

signal slave_selected(slave: SlaveNode)
signal slave_mouse_entered(slave: SlaveNode)
signal slave_mouse_exited(slave: SlaveNode)

signal speed_queue_mouse_entered(slave: Slave)
signal speed_queue_mouse_exit(slave: Slave)

signal slave_info(slave: Slave)
signal enemy_info(slave: Slave)

signal reinforcement(enemy: Enemy, u_name: String)
signal slave_death(slave: SlaveNode)
signal slave_undeath(slave: SlaveNode)
signal slave_ran(slave: SlaveNode)

signal evil_won
signal good_won

signal show_end_battle_screen(scraps: Array[Item.Scrap])
signal end_battle

# ====================
# Team Window
# ====================

signal open_team_window

signal add_item(item: Item)
signal show_item_info(item: Item)
signal hide_item_info

# ====================
# Room encounters
# ====================

# tips

signal check_city(city: Room)
signal check_comms(comms: Room)
signal check_elevator(elevator: Room)


# for triggers
signal entered_room(room: Room)

signal battle_encounter

signal teleport(to: int)

signal found_item
signal enter_city(city: Room)
signal enter_govnov
signal enter_comms(comms: Room)
signal enter_elevator(elevator: Room)
signal change_steps(delta: int)
signal city_heal
signal govnov_heal
