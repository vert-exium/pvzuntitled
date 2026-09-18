extends Node2D

var master_bus_index: int
var sfx_bus_index: int
var music_bus_index: int

# Called when the node enters the scene tree for the first time.
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

func _on_master_volume_slider_value_changed(new_value: float) -> void:
	var master_vol_db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(master_bus_index, master_vol_db)
	$masterVol.text = "Master Volume: " + str(int(new_value * 100)) + "%"


func _on_sfx_volume_slider_value_changed(new_value: float) -> void:
	var sfx_vol_db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(sfx_bus_index, sfx_vol_db)
	$sfxVol.text = "SFX Volume: " + str(int(new_value * 100)) + "%"


func _on_music_volume_slider_value_changed(new_value: float) -> void:
	var music_vol_db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(music_bus_index, music_vol_db)
	$musicVol.text = "Music Volume: " + str(int(new_value * 100)) + "%"
