extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		if(self.name == "EndOfSecondRoom"):
			get_tree().change_scene_to_file("res://src/Scenes/space.tscn")
			print("end of tutorial teleport")
		elif(self.name == "EndOfSpaceOne"):
			get_tree().change_scene_to_file("res://src/Scenes/Levels/Level1.tscn")
			print("ship to level one teleport")
		elif(self.name == "SecondLevel"):
			get_tree().change_scene_to_file("res://src/Scenes/Levels/Level2.tscn")
			print("level one to level two teleport")
		elif(self.name == "TeleportLvl2"):
			get_tree().change_scene_to_file("res://src/Scenes/Levels/Level3.tscn")
		elif(self.name == "EndGame"):
			get_tree().change_scene_to_file("res://src/Scenes/end_screen.tscn")
		else:
			body.set_position($Destination.global_position)
			print("teleport")
	else:
		print("test")
