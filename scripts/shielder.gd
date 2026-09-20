extends Area2D

@onready var fire_timer = $attackTimer
@onready var raycast = $RayCast2D
var projectile_scene = preload("res://scenes/shielder_projectile.tscn")


var health: int = 0

func _ready() -> void:
	var stats = CardDatabase.get_card("shielder")
	health = stats["health"]
	
	fire_timer.wait_time = stats["fire_rate"]
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()

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

func fire_projectile() -> void:
	$AnimatedSprite2D.play("default")
	var proj = projectile_scene.instantiate()
	proj.global_position = global_position + Vector2(100, 0)
	get_tree().current_scene.add_child(proj)
