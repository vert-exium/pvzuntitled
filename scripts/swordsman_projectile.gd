extends Area2D

@export var damage: int = 25
@export var knockback_force: float = 50.0  
@export var is_knockback_projectile: bool = true
var speed = 0

func _ready() -> void:
	add_to_group("knockback_projectile")

func _process(delta: float) -> void:
	position.x += speed * delta 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		$AnimatedSprite2D.play("swordslash")
		area.take_damage(damage)



func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
