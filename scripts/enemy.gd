extends Area2D

var base_speed: float = 30.0
var current_speed: float = 30.0
var health: int = 100
var attack_damage: int = 10
var current_target: Area2D = null

@onready var attack_timer: Timer = $AttackTimer
var lane: int = 0

func _ready() -> void:
	add_to_group("enemy") # Fixes splash/projectile group checks
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	area_entered.connect(_on_area_entered)
	# APPLY WAVE SCALING HERE WHEN THE ENEMY SPAWNS:
	base_speed = 30.0 * LevelManager.speed_scale
	current_speed = base_speed
	attack_damage = int(10 * LevelManager.dmg_scale)
	
	print("[DEBUG] Spawned Enemy -> Speed: %.1f | Damage: %d" % [current_speed, attack_damage])
func _process(delta: float) -> void:
	position.x -= current_speed * delta
	if current_speed < 1.0:
		$enemyAnimation.stop()
	else:
		$enemyAnimation.play("default")

func take_damage(amount: int) -> void:
	health -= amount
	modulate = Color.RED
	scale = Vector2(0.8, 0.9)
	
	var hit_tween = create_tween().set_parallel(true)
	hit_tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	hit_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
	
	if health <= 0:
		current_speed = 0.0
		hit_tween.kill()
		
		if LevelManager.has_method("enemy_defeated"):
			LevelManager.enemy_defeated()
		
		var death_tween = create_tween().set_parallel(true)
		death_tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
		death_tween.tween_property(self, "modulate", Color.DARK_RED, 0.3)
		death_tween.chain().tween_callback(queue_free)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("unit") and current_target == null:
		start_attacking(area)
	
	if area.name == "DeathZone":
		LevelManager.enemy_reached_end()
		queue_free()

func _on_area_exited(area: Area2D) -> void:
	if area == current_target:
		check_next_target()

func start_attacking(target: Area2D) -> void:
	current_speed = 0.0
	current_target = target
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	if is_instance_valid(current_target):
		current_target.take_damage(attack_damage)
		position.x -= 5
		create_tween().tween_property(self, "position:x", position.x + 5, 0.2)
	else:
		check_next_target()

func check_next_target() -> void:
	var overlapping_units = get_overlapping_areas()
	for area in overlapping_units:
		if area.is_in_group("unit") and is_instance_valid(area):
			start_attacking(area)
			return
			
	# Resume walking at the scaled base_speed
	current_target = null
	current_speed = base_speed  # Uses the scaled speed calculated in _ready()
	attack_timer.stop()
