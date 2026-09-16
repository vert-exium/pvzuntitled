extends Node

signal energy_changed(new_amount)
signal card_cooldown_started(card_id, duration)

signal plant_placed(card_id, grid_pos)
signal plant_shoveled(grid_pos)

signal wave_started(wave_number)
signal enemy_spawned(enemy_id, lane_index)

signal game_over
signal level_won

signal card_selected(card_id)
