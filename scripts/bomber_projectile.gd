extends Area2D

var speed: float = 250.0
var damage: int = 50
var explosionScene = preload("res://scenes/explosion_splash.tscn")



func _ready():
	$bomb.play("bomb")

func _process(delta: float) -> void:
	position.x += speed * delta 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		explode()
		area.take_damage(damage)
		queue_free()

func explode():
	var explosion_instance = explosionScene.instantiate()
	explosion_instance.global_position = global_position
	get_parent().add_child(explosion_instance)
