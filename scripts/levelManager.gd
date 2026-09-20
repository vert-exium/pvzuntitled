extends Node

var current_wave: int = 0
var max_waves: int = 10
var is_game_active: bool = false
var is_wave_transitioning: bool = false  

# Scaling factors
var speed_scale: float = 1.0
var dmg_scale: float = 1.0

# Wave Spawning State
var enemies_left_to_spawn: int = 0
var active_enemies_count: int = 0

@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start_level() -> void:
	current_wave = 0
	is_game_active = true
	is_wave_transitioning = false
	print("========================================")
	print("[DEBUG] Level Started!")
	print("========================================")
	_start_next_wave()

func _start_next_wave() -> void:
	if not is_game_active: 
		return
	
	is_wave_transitioning = false #
	current_wave += 1
	
	if current_wave > max_waves:
		is_game_active = false
		print("[DEBUG] All waves completed! LEVEL WON!")
		SignalBus.level_won.emit()
		return

	SignalBus.wave_started.emit(current_wave)
	
	# Calculation: Enemies per wave
	enemies_left_to_spawn = 5 + (current_wave - 1) * 3
	active_enemies_count = 0
	
	# Stat scaling
	speed_scale = 1.0 + (current_wave - 1) * 0.2
	dmg_scale = 1.0 + (current_wave - 1) * 0.4
	
	print("----------------------------------------")
	print("[DEBUG] WAVE %d / %d STARTED" % [current_wave, max_waves])
	print("[DEBUG] Total Enemies to Spawn: %d" % enemies_left_to_spawn)
	print("[DEBUG] Speed Multiplier: %.2fx | Damage Multiplier: %.2fx" % [speed_scale, dmg_scale])
	print("----------------------------------------")
	
	var spawn_delay = max(0.8, 3.0 - (current_wave * 0.2))
	spawn_timer.start(spawn_delay)

func _on_spawn_timer_timeout() -> void:
	if not is_game_active or enemies_left_to_spawn <= 0:
		spawn_timer.stop()
		return

	SignalBus.request_enemy_spawn.emit()
	
	enemies_left_to_spawn -= 1
	active_enemies_count += 1
	
	if enemies_left_to_spawn <= 0:
		print("[DEBUG] All enemies for Wave %d spawned! Waiting for remaining enemies to be defeated..." % current_wave)
		spawn_timer.stop()

func enemy_defeated() -> void:
	if not is_game_active: 
		return
		
	active_enemies_count = max(0, active_enemies_count - 1)
	

	if enemies_left_to_spawn <= 0 and active_enemies_count == 0 and not is_wave_transitioning:
		is_wave_transitioning = true  
		
		print("========================================")
		print("[DEBUG] Wave %d CLEARED!" % current_wave)
		print("[DEBUG] Starting 5-second cooldown before Wave %d..." % (current_wave + 1))
		print("========================================")
		
		get_tree().create_timer(5.0).timeout.connect(_start_next_wave)

func enemy_reached_end() -> void:
	if is_game_active:
		is_game_active = false
		spawn_timer.stop()
		print("========================================")
		print("[DEBUG] GAME OVER - Enemy reached the end!")
		print("========================================")
		SignalBus.game_over.emit()
