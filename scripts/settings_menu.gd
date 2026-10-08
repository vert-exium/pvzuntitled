extends Node2D

# Variables to store the indexes
# of all 3 audio buses.
var master_bus_index: int
var sfx_bus_index: int
var music_bus_index: int


# When the node starts, gets all 3 audio bus indexes,
# and stores them in the variables from earlier.
# Also sets up the volume sliders values by translating
# the volumes of the indexes to a linear value and setting
# the slider values accordingly.
# Finally, sets the labels to show the current % volume
# in a clean manner (in integers)

func _ready() -> void:
	master_bus_index = AudioServer.get_bus_index("Master")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	music_bus_index = AudioServer.get_bus_index("Music")
	$masterVolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))
	$masterVol.text = "Master Volume: " + str(int($masterVolumeSlider.value * 100)) + "%"
	$sfxVolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))
	$sfxVol.text = "SFX Volume: " + str(int($sfxVolumeSlider.value * 100)) + "%"
	$musicVolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	$musicVol.text = "Music Volume: " + str(int($sfxVolumeSlider.value * 100)) + "%"

# When the master volume slider is changed, translates the linear value
# to a decibel value, and sets the bus volume to that db value. Then,
# updates the label's text to display the new value in a percentage.
func _on_master_volume_slider_value_changed(new_value: float) -> void:
	var master_vol_db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(master_bus_index, master_vol_db)
	$masterVol.text = "Master Volume: " + str(int(new_value * 100)) + "%"

# (Same thing as the master vol slider but for sfx slider)
# When the sfx volume slider is changed, translates the linear value
# to db value, and sets the bus volume accordingly. Then, updates the
# label to reflect the new value as a percentage.
func _on_sfx_volume_slider_value_changed(new_value: float) -> void:
	var sfx_vol_db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(sfx_bus_index, sfx_vol_db)
	$sfxVol.text = "SFX Volume: " + str(int(new_value * 100)) + "%"

# (Same thing but for the music volume slider)
# When the music volume slider is changed, translate the new linear
# value to decibels. Then, changes the correct bus accordingly, and
# updates the label to reflect the change.
func _on_music_volume_slider_value_changed(new_value: float) -> void:
	var music_vol_db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(music_bus_index, music_vol_db)
	$musicVol.text = "Music Volume: " + str(int(new_value * 100)) + "%"

# Changes the scene to the main menu when the button is pressed.
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
