extends Control

#variables
var master_vol = AudioServer.get_bus_index("Master")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Options_Menu.tscn")
	


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_vol, value)

func _on_mute_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(master_vol, not AudioServer.is_bus_mute(master_vol))
