extends Area2D

@export var speed: float = 30.0
@export var health: int = 100
var lane: int = 0

func _process(delta: float) -> void:
	position.x -= speed * delta


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "DeathZone":
		LevelManager.enemy_reached_end()
		queue_free()
