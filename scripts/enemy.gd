extends Area2D

var base_speed: float = 30.0
var current_speed: float = 30.0
var health: int = 100
var attack_damage: int = 10
var current_target: Area2D = null

@onready var attack_timer = $AttackTimer
var lane: int = 0

func _ready() -> void:
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	area_entered.connect(_on_area_entered)
	

func _process(delta: float) -> void:
	position.x -= current_speed * delta


func take_damage(amount: int) -> void:
	print("enemy took damage" + str(amount))
	health -= amount
	modulate = Color.RED
	scale = Vector2(0.8, 0.9) 
	
	var hit_tween = create_tween().set_parallel(true)
	hit_tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	hit_tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
	
	if health <= 0:
		current_speed = 0
		
		
		hit_tween.kill() 
		
		var death_tween = create_tween().set_parallel(true)
		death_tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
		death_tween.tween_property(self, "modulate", Color.DARK_RED, 0.3)
		
		death_tween.chain().tween_callback(queue_free)
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("unit"):
		current_speed = 0
		current_target = area
		attack_timer.start()
	
	if area.name == "DeathZone":
		LevelManager.enemy_reached_end()
		queue_free()

func _on_attack_timer_timeout() -> void:
	if is_instance_valid(current_target):
		current_target.take_damage(attack_damage)
		
		position.x -= 5
		create_tween().tween_property(self, "position:x", position.x + 5, 0.2)
	else:
		current_target = null
		current_speed = base_speed
		attack_timer.stop()
