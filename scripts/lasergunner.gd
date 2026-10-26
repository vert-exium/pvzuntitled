extends Area2D

# When the node loads in, grabs the attack timer
# and raycast nodes and stores them in variables.
@onready var fire_timer = $attackTimer
@onready var raycast = $RayCast2D

# Preloads the projectile scene and stores it in a variable.
var projectile_scene = preload("res://scenes/lasergunner_projectile.tscn")

# Stores the health of the unit in a variable
var health: int = 0

func _ready() -> void:
	var stats = CardDatabase.get_card("lasergunner")
	health = stats["health"] * Global.health_boost
	
	fire_timer.wait_time = stats["fire_rate"] / Global.attackSpeed_boost
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()
	
	# Connect to frame_changed to reliably trigger events on specific frames
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)

func _on_fire_timer_timeout() -> void:
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.is_in_group("enemy"):
			fire_projectile()

func take_damage(amount: int) -> void:
	health -= amount
	
	modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	
	if health <= 0:
		queue_free()

# When an attack is requested, plays the attack animation
func fire_projectile() -> void:
	$AnimatedSprite2D.play("default")
	$AudioStreamPlayer2D.play()

# Listens for frame changes to spawn the projectile exactly once at frame 4
func _on_frame_changed() -> void:
	$AnimatedSprite2D.speed_scale = Global.attackSpeed_boost
	
	if $AnimatedSprite2D.animation == "default" and $AnimatedSprite2D.frame == 4:
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + Vector2(50, -20)
		get_tree().current_scene.add_child(proj)
