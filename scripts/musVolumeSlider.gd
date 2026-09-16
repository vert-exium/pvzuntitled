extends HSlider



func _on_value_changed(value: int) -> void:
	print(value)
	$"../musicVol".text = "Volume: " + str(value) + "%"
	pass # Replace with function body.
