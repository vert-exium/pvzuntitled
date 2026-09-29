extends Area2D

# Defining variables
var speed: float = 350.0
var rotSpeed: float = 3.5
var damage: int = 50
var soundPitch: float = 1.0
var explosionScene = preload("res://scenes/explosion_splash.tscn")


# When the projectile spawns in, instantly play the animation.
func _ready():
	$bomb.play("throw")

# Constantly moves and rotates
func _process(delta: float) -> void:
	position.x += speed * delta 
	rotation += rotSpeed * delta

# If the projectile enters an Area2D, checks if it is an enemy, 
# triggers the explosion, deals damage, and despawns.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		explode()
		area.take_damage(damage)
		queue_free()

# Spawns in the explosion, sets it's position, and then despawns itself.
func explode():
	var explosion_instance = explosionScene.instantiate()
	explosion_instance.global_position = global_position
	get_parent().add_child.call_deferred(explosion_instance)
	queue_free()
