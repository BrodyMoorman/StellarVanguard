extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# work in progress
# creates the options menu as a child scene of another scene
func _optionsStart() -> void:
	pass
	#var scene = preload("res://src/Scenes/Options_menu.tscn")

# returns to the main menu when the back button is called
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Main_Menu.tscn")

func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Controls_Menu.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Settings_Menu.tscn")
