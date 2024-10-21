extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if(self.name == "EndOfSecondRoom"):
			get_tree().change_scene_to_file("res://src/Scenes/space.tscn")
		else:
			body.set_position($Destination.global_position)
			print("teleport")
	else:
		print("test")
