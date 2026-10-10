extends Area2D

# When the node loads in, grabs the attack timer
# and raycast nodes and stores them in variables.
@onready var fire_timer = $attackTimer
@onready var raycast = $RayCast2D

# Preloads the projectile scene and stores it in a variable.
var projectile_scene = preload("res://scenes/projectile.tscn")

# Stores the health of 
# the unit in a variable
var health: int = 0

# When the node loads in, loads the dictionary for the
# thrower card specifically, and sets the health and
# cooldowns accordingly. Also connects the timeout 
# signal to a function and starts the timer.
func _ready() -> void:
	var stats = CardDatabase.get_card("thrower")
	health = stats["health"]
	
	fire_timer.wait_time = stats["fire_rate"]
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()

# When the cooldown is over, checks if the raycast is
# colliding with anything. If it is, checks if the 
# object it's detecting is an enemy. If so, triggers
# the firing of the projectile.
func _on_fire_timer_timeout() -> void:
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.is_in_group("enemy"):
			fire_projectile()

# Function to take damage. Deducts the amount of
# damage needed, and then tweens the color of the 
# character to red. If the health is under 0,
# despawns the character.
func take_damage(amount: int) -> void:
	health -= amount
	
	modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	
	if health <= 0:
		queue_free()

# When an attack is requested, starts the attack animation.
func fire_projectile() -> void:
	$pitcherAnimation.play("attack")

# Every frame, checks if the animation has reached the correct frame 
# to fire while looking smooth. If so, spawns in the projectile, offsets
# it so it spawns in the hand, and adds the projectile as a child. Also 
# progresses the frame so the function does not run many times.
func _process(delta: float) -> void:
	if $pitcherAnimation.frame == 14:
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position + Vector2(-20, -56)
		get_tree().current_scene.add_child(proj)
		$pitcherAnimation.frame = 15
