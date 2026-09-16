extends Node

var current_wave: int = 0
var max_waves: int = 10
var is_game_active: bool = false

func start_level() -> void:
	current_wave = 0
	is_game_active = true
	_start_next_wave()

func _start_next_wave() -> void:
	if not is_game_active: return
	
	current_wave += 1
	SignalBus.wave_started.emit(current_wave)
	
	if current_wave > max_waves:
		is_game_active = false
		SignalBus.level_won.emit()

func enemy_reached_end() -> void:
	if is_game_active:
		is_game_active = false
		SignalBus.game_over.emit()
