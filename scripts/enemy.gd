extends Area2D

var base_speed: float = 30.0
var current_speed: float = 30.0
var health: int = 100
var attack_damage: int = 10
var current_target: Area2D = null
var pitch_random: float = 0
@onready var attack_timer: Timer = $AttackTimer
@export var enemy_id = ""
var lane: int = 0

#Table of enemy stats
#enemy gets stats assigned
const enemy_stats = {
	"normal": {
		"name": "normal",
		"base_speed": 30.0,
		"health": 100,
		"attack_damage": 10,
		"attack_speed": 2.0,
		"enemy_weight": 1.0
	},
	"tank": {
		"name": "tank",
		"base_speed": 20,
		"health": 300,
		"attack_damage": 5,
		"attack_speed": 1.0,
		"enemy_weight": 2
	}
}

func _ready() -> void:
	#Assign enemy to the right stats
	var stats = enemy_stats.get(enemy_id, enemy_stats["normal"])
	print(enemy_id)
	$AttackTimer.wait_time = stats["attack_speed"]
	add_to_group("enemy") # Fixes splash/projectile group checks
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	area_entered.connect(_on_area_entered)
	# APPLY WAVE SCALING HERE WHEN THE ENEMY SPAWNS:
	base_speed = stats["base_speed"] * LevelManager.speed_scale
	current_speed = base_speed
	attack_damage = int(stats["attack_damage"] * LevelManager.dmg_scale)
	health = int(stats["health"] * LevelManager.speed_scale)
func _process(delta: float) -> void:
	#animations
	position.x -= current_speed * delta
	if current_speed < 1.0:
		pass
	else:
		#Play walking anim if its moving
		$enemyAnimation.play("default")

func take_damage(amount: int) -> void:
	#play hit sounds
	pitch_random = randf_range(0.9,1.1)
	$AudioStreamPlayer2D.pitch_scale = pitch_random
	$AudioStreamPlayer2D.playing = true
	#make enemy take damage and effects
	health -= amount
	modulate = Color.RED
	scale = Vector2(0.8, 0.9)
	
	var hit_tween = create_tween().set_parallel(true)
	hit_tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	hit_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
	#kill enemy
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
	if area.is_in_group("knockback_projectile"):
		var force = area.get("knockback_force") if "knockback_force" in area else 40.0
		var damage = area.get("damage") if "damage" in area else 10
		take_damage(damage)
		apply_knockback(force)
		# Destroy projectile
		if area.has_method("destroy"):
			area.destroy()
		else:
			area.queue_free()

	elif area.is_in_group("unit") and current_target == null:
		start_attacking(area)

	elif area.name == "DeathZone":
		LevelManager.enemy_reached_end()
		queue_free()

func _on_area_exited(area: Area2D) -> void:
	#Looks for next target
	if area == current_target:
		check_next_target()

func start_attacking(target: Area2D) -> void:
	#Play attack anim
	$enemyAnimation.play("attack")
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
	
	
	
	#looks for next target
	var overlapping_units = get_overlapping_areas()
	for area in overlapping_units:
		if area.is_in_group("unit") and is_instance_valid(area):
			start_attacking(area)
			return
			
	current_target = null
	current_speed = base_speed 
	attack_timer.stop()


func apply_knockback(distance: float):
	if current_target != null:
		current_target = null
		attack_timer.stop()
	var target_x = position.x + distance
	var knock_tween = create_tween()
	knock_tween.tween_property(self, "position:x", target_x, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	knock_tween.finished.connect(func():
		if current_target == null:
			current_speed = base_speed
)
