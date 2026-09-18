extends Node2D

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
