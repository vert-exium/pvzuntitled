extends Area2D

var speed: float = 0
var damage: int = 10

func _process(delta: float) -> void:
	position.x += speed * delta 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
