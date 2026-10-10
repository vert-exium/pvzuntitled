extends Area2D

# Variables for damage/speed
var speed: float = 250.0
var damage: int = 10

# Every frame, moves the position of the projectile, and
# rotates it as well.
func _process(delta: float) -> void:
	position.x += speed * delta 
	rotation_degrees += 2

# When an Area2D is entered, checks if the area is
# an enemy and it can take damage. If so, makes 
# the area take damage and despawns the projectile.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
