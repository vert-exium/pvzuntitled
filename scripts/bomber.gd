extends Area2D

# Defines variables
@onready var fire_timer = $attackTimer
@onready var raycast = $RayCast2D
var projectile_scene = preload("res://scenes/bomber_projectile.tscn")

var health: int = 0

# On ready, loads all stats into a variable and starts the fire timer
func _ready() -> void:
	var stats = CardDatabase.get_card("bomber")
	health = stats["health"]
	fire_timer.wait_time = stats["fire_rate"]
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()

# When the fire cooldown ends, checks if an enemy is present. If so, fires a projectile.
func _on_fire_timer_timeout() -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.is_in_group("enemy"):
			fire_bomb()

# Takes damage, applies a red glow effect, and despawns the unit if health is less than zero.
func take_damage(amount: int) -> void:
	health -= amount
	
	modulate = Color(1, 0.3, 0.3, 0.9)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	
	if health <= 0:
		queue_free()

# Starts the animation to attack
func fire_bomb() -> void:
	$animation.play("attack")


# Checks if the animation has reached the correct frame. If so, changes the frame so the loop doesn't repeat,
# and spawns the projectile in the correct position.
func _process(delta: float) -> void:
	if $animation.frame == 18:
		$animation.frame = 19
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + Vector2(-43, -60)
		get_tree().current_scene.add_child(proj)
