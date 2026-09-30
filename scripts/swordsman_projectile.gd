extends Area2D

var speed: float = 0
var damage: int = 50
var is_hit: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("swordslash")

func _process(delta: float) -> void:
	if not is_hit:
		position.x += speed * delta

func _on_area_entered(area: Area2D) -> void:
	if is_hit:
		return

	if area.is_in_group("enemy") and area.has_method("take_damage"):
		is_hit = true
		area.take_damage(damage)
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
