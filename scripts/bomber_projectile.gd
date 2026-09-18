extends Area2D

var speed: float = 200.0
var damage: int = 10
var random_rotation = RandomNumberGenerator.new()

func _ready() -> void:
	random_rotation = randi_range(0.3, 1.0)

func _process(delta: float) -> void:
	position.x += speed * delta 
	rotation_degrees += random_rotation
	random_rotation.randomize()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
