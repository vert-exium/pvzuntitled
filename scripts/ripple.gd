extends Control

var radius: float = 4.0
var max_radius: float = 120.0
var alpha: float = 1.0
var duration: float = 1.6

func _ready() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "radius", max_radius, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "alpha", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1, 1, 1, alpha * 0.8), 2.0, true)
	
	var inner_radius = radius * 0.55
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 32, Color(1, 1, 1, alpha * 0.35), 1.0, true)
	
	if radius < 25.0:
		var dot_alpha = (1.0 - (radius / 25.0)) * alpha
		draw_circle(Vector2.ZERO, 3.0, Color(1, 1, 1, dot_alpha))
