extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collision_shape_2d_tree_entered() -> void:
	get_tree().change_scene_to_file("res://src/scenes/level_complete.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
