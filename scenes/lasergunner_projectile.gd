extends Area2D

# Variables for damage/speed
var speed: float = 500.0
var damage: int = 100

func _ready() -> void:
	#Add damage boost from global script
	damage *= Global.damage_boost

# Every frame, moves the position of the projectile, and
# rotates it as well.
func _process(delta: float) -> void:
	position.x += speed * delta 

# When an Area2D is entered, checks if the area is
# an enemy and it can take damage. If so, makes 
# the area take damage and despawns the projectile.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
