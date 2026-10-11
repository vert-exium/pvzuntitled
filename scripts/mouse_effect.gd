extends Control

var anim_scale: float = 0.2
var max_scale: float = 1.4
var rot_angle: float = 0.0
var alpha: float = 1.0
var duration: float = 0.35

func _ready() -> void:
	max_scale = randf_range(1.0,1.8)
	rotation = randf_range(0.0, TAU)
	duration = randf_range(0.3,0.5)


	var tween = create_tween().set_parallel()
	tween.tween_property(self, "anim_scale", max_scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rot_angle", PI * 0.75, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "alpha", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
#Draw diamond
	var points = PackedVector2Array([
		Vector2(0, -24),
		Vector2(6, -6),
		Vector2(24, 0),
		Vector2(6, 6),
		Vector2(0, 24),
		Vector2(-6, 6),
		Vector2(-24, 0),
		Vector2(-6, -6)
	])
	
	draw_set_transform(Vector2.ZERO, rot_angle, Vector2(anim_scale, anim_scale))
	
	#outer layer
	draw_colored_polygon(points, Color(0.4, 0.8, 1.0, alpha * 0.3))
	
# Inner
	var inner_points = PackedVector2Array()
	for p in points:
		inner_points.append(p * 0.5)
	
	draw_colored_polygon(inner_points, Color(1.0, 1.0, 1.0, alpha * 0.9))
