extends Control

var scene = preload("res://src/Scenes/Options_Menu.tscn")
var master_vol = AudioServer.get_bus_index("Master")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resume_game_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Engine.time_scale = 1

func _on_quit_game_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://src/Scenes/Main_Menu.tscn")

func _on_mute_pressed() -> void:
	AudioServer.set_bus_mute(master_vol, not AudioServer.is_bus_mute(master_vol))

func _on_select_level_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://src/Scenes/level_select.tscn")
