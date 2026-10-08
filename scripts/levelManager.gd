extends Node

var current_wave: int = 0
var max_waves: int = 10
var is_game_active: bool = false
var is_wave_transitioning: bool = false   

# Scaling factors
var speed_scale: float = 1.0
var dmg_scale: float = 1.0
var hp_scale: float = 1.0

# Wave Weight State
var wave_budget: float = 0.0
var remaining_budget: float = 0.0
var active_enemies_count: int = 0

@onready var spawn_timer: Timer = Timer.new()


#Creates a timer
func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
#Starts the level
#sets wave to 0
func start_level() -> void:
	current_wave = 0
	is_game_active = true
	is_wave_transitioning = false
	_start_next_wave()
#Increases the current wave
#Checks if current wave is larger than max waves, emitting "won" signal if true
func _start_next_wave() -> void:
	if not is_game_active: 
		return
	
	is_wave_transitioning = false
	current_wave += 1
	
	if current_wave > max_waves:
		is_game_active = false
		print("[DEBUG] All waves completed! LEVEL WON!")
		SignalBus.level_won.emit()
		return

	SignalBus.wave_started.emit(current_wave)
	
	# Calculation: Total Budget for this wave
	wave_budget = 5.0 + (current_wave - 1) * 3.5
	remaining_budget = wave_budget
	active_enemies_count = 0
	
	# Stat scaling
	speed_scale = 1.0 + (current_wave - 1) * 0.4
	dmg_scale = 1.0 + (current_wave - 1) * 0.2
	hp_scale = 1.0 + (current_wave - 1) * 0.2
	
	print("----------------------------------------")
	print("[DEBUG] WAVE %d / %d STARTED" % [current_wave, max_waves])
	print("[DEBUG] Total Wave Budget: %.1f" % wave_budget)
	print("[DEBUG] Speed Multiplier: %.2fx | Damage Multiplier: %.2fx" % [speed_scale, dmg_scale])
	print("Health mult: " + str(hp_scale))
	print("----------------------------------------")
	
	var spawn_delay = max(0.8, 3.0 - (current_wave * 0.2))
	spawn_timer.start(spawn_delay)
func _on_spawn_timer_timeout() -> void:
	if not is_game_active or remaining_budget < 1.0: # 1.0 is the minimum cost (Normal enemy)
		spawn_timer.stop()
		return

	# Passes the remaining budget to Spawner
	SignalBus.request_enemy_spawn.emit(remaining_budget)

func register_spawned_enemy(weight_cost: float) -> void:
	# Called by the spawner when an enemy is chosen and spawned
	#Subtracts weight of enemy from the remaining  budget (once spawned)
	#Increases active enemy count
	remaining_budget -= weight_cost
	active_enemies_count += 1
	#If nothing can be bought within the remaning budget, stop spawning stuff
	if remaining_budget < 1.0:
		print("[DEBUG] Budget is out for Wave %d! Waiting for remaining enemies..." % current_wave)
		spawn_timer.stop()
func enemy_defeated() -> void:
	if not is_game_active: 
		return
		
	active_enemies_count = max(0, active_enemies_count - 1)
#when the budget is greater than one, there are no enemies, and it is not during the wave transition:
#Start the wave transition
#create a 5 second "break" between waves and connect it to start next wave on timeout
	if remaining_budget < 1.0 and active_enemies_count == 0 and not is_wave_transitioning:
		is_wave_transitioning = true  
		get_tree().create_timer(5.0).timeout.connect(_start_next_wave)
#Emit game over when enemy reaches the end
func enemy_reached_end() -> void:
	if is_game_active:
		is_game_active = false
		spawn_timer.stop()
		print("========================================")
		print("[DEBUG] GAME OVER - Enemy reached the end!")
		print("========================================")
		SignalBus.game_over.emit()
