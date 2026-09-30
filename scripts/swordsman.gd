extends Area2D

@onready var fire_timer = $attackTimer
@onready var raycast = $RayCast2D
@onready var animated_sprite = $AnimatedSprite2D

var projectile_scene = preload("res://scenes/swordsman_projectile.tscn")
var health: int = 0

func _ready() -> void:
	var stats = CardDatabase.get_card("swordsman")
	health = stats["health"]
	
	fire_timer.wait_time = stats["fire_rate"]
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()
	
	# Connect sprite signals for timing and reset
	animated_sprite.frame_changed.connect(_on_frame_changed)
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_fire_timer_timeout() -> void:
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.is_in_group("enemy"):
			fire_projectile()

func fire_projectile() -> void:
	animated_sprite.play("sword swing")

func _on_frame_changed() -> void:
	# Spawns projectile when "sword swing" hits frame 4
	if animated_sprite.animation == "sword swing" and animated_sprite.frame == 4:
		spawn_projectile()

func spawn_projectile() -> void:
	var proj = projectile_scene.instantiate()
	proj.global_position = global_position + Vector2(100, 0)
	get_tree().current_scene.add_child(proj)

func _on_animation_finished() -> void:
	# Stops animation and resets to frame 0 once completed
	if animated_sprite.animation == "sword swing":
		animated_sprite.stop()
		animated_sprite.frame = 0

func take_damage(amount: int) -> void:
	health -= amount
	
	modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	
	if health <= 0:
		queue_free()
