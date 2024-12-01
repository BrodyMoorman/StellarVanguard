extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# loads a fresh game when clicked
func _on_start_button_pressed() -> void: 
	get_tree().change_scene_to_file("res://src/Scenes/level_select.tscn")

# loads the options menu when clicked
func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Options_Menu.tscn")

# quits the game
func _on_quit_button_pressed() -> void:
	get_tree().quit()
