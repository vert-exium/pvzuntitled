extends Control
#Unit textures
var swordsman_texture = load("res://images/323-3232939_pixel-art-sword-sword-pixel-art-transparent-hd-removebg-preview.png")
var bomber_texture = load("res://images/image_2026-09-18_233811005-removebg-preview.png")
var shielder_texture = load("res://images/5723525.png")
var thrower_texture = load("res://images/images__5_-removebg-preview.png")
var generator_texture = load("res://images/image_2026-09-18_234043813-removebg-preview.png")
#Enemy textures
var normal_texture = load("res://images/image_2026-10-05_164029134-removebg-preview.png")
var tank_texture = load("res://images/image_2026-10-05_170904917-removebg-preview (1).png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#changes colors of labels
	if $unitsButton.is_hovered():
		$unitsButton/unitsLabel.add_theme_color_override("font_color", Color.GREEN)
	else:
		$unitsButton/unitsLabel.add_theme_color_override("font_color", Color.WHITE)
	if $enemiesButton.is_hovered():
		$enemiesButton/enemyLabel.add_theme_color_override("font_color", Color.GREEN)
	else:
		$enemiesButton/enemyLabel.add_theme_color_override("font_color", Color.WHITE)

#switches to unit tab
func _on_units_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/index.tscn")
#switches to enemy tab
func _on_enemies_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/enemy_index.tscn")
#unit descriptions + stats
func _on_swordsman_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Swordsman"
	$spritePreview.texture = swordsman_texture
	$unitpreviewbox/cardStats.text = "Cost: 600 \nPlacement Cooldown: 20 seconds \nHealth: 250 \nDamage: 25 \nAttack Rate: 1s \nKnockback: 50 pixels"
	$unitpreviewbox/cardDescription.text = "Description: \nThe swordsman is a very useful and versatile card. It attacks quickly and does high damage to all enemies in its range. It is great for dealing with weaker enemies quickly."

func _on_bomber_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Bomber"
	$spritePreview.texture = bomber_texture
	$unitpreviewbox/cardStats.text = "Cost: 500 \nPlacement Cooldown: 10 seconds \nHealth: 200 \nDirect hit damage: 25 \nExplosion Damage: 25 \nAttack Rate: 4s"
	$unitpreviewbox/cardDescription.text = "Description: \nThe bomber is a great card for dealing with crowds. The enemy it hits takes a total of 50 damage and nearby enemies take 25 damage. This makes it decimate groups of enemies with ease."
func _on_shielder_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Shielder"
	$spritePreview.texture = shielder_texture
	$unitpreviewbox/cardStats.text = "Cost: 350 \nPlacement Cooldown: 15 seconds \nHealth: 400 \nDamage: 5 \nAttack Rate: 1.5s"
	$unitpreviewbox/cardDescription.text = "Description: \nThe shielder is a high HP card with low damage and range. Its high HP allows it to soak up a lot of damage."
func _on_thrower_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Thrower"
	$spritePreview.texture = thrower_texture
	$unitpreviewbox/cardStats.text = "Cost: 100 \nPlacement Cooldown: 10 seconds \nHealth: 150 \nDamage: 10 \nAttack Rate: 1.5s"
	$unitpreviewbox/cardDescription.text = "Description: \nThe thrower is a cheap tower with low stats. The thrower is great for the early game as it is very cheap."
func _on_generator_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Generator"
	$spritePreview.texture = generator_texture
	$unitpreviewbox/cardStats.text = "Cost: 50 \nPlacement Cooldown: 8 seconds \nHealth: 100 \nEnergy output: 15 \nEnergy Tick Rate: 5s"
	$unitpreviewbox/cardDescription.text = "Description: \nThe generator is a unit which generates energy passivley."
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
#Enemy descriptions:
func _on_normal_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Normal"
	$spritePreview.texture = normal_texture
	$unitpreviewbox/cardStats.text = "Health: 100 \nSpeed: 30\nDamage: 10 \nAttack Rate: 2s"
	$unitpreviewbox/cardDescription.text = "Decription: \nYour average enemy with average stats. Easy to kill."

func _on_tank_button_pressed() -> void:
	$unitpreviewbox/cardDescription.text = "Tank"
	$spritePreview.texture = tank_texture
	$unitpreviewbox/cardStats.text = "Health: 300 \nspeed: 20 \nDamage: 5 \nAttack Rate: 1s"
	$unitpreviewbox/cardDescription.text = "Description: \nA slow enemy with high health. This enemy will soak up a lot of damage, be careful! Beware of its boxing glove (deadly)."
