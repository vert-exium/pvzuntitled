extends Area2D

var speed: float = 350
var damage: int = 30

func _ready() -> void:
	$arrow.play("arrow")

func _process(delta: float) -> void:
	position.x += speed * delta 
#when the projectile hits an enemy, and it can take damage
#make the enemy take damage (in this case 30, as it is set at the top)
#delete the projectile on contact
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
