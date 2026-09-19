extends Area2D

@onready var color_rect: ColorRect = $ColorRect
var damage = 25


func _ready() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)

func _on_timer_timeout() -> void:
	queue_free()
