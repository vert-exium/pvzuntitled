extends Control

var swordsman_texture = load("res://images/323-3232939_pixel-art-sword-sword-pixel-art-transparent-hd-removebg-preview.png")
var bomber_texture = load("res://images/image_2026-09-18_233811005-removebg-preview.png")



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


func _on_units_button_pressed() -> void:
	pass


func _on_swordsman_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Swordsman"
	$spritePreview.texture = swordsman_texture

func _on_bomber_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Bomber"

func _on_shielder_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Shielder"

func _on_thrower_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Thrower"

func _on_generator_button_pressed() -> void:
	$unitpreviewbox/cardNamePreview.text = "Generator"
