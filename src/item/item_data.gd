extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var equipable: bool = false
@export var texture: Texture2D

func use(target, index) -> void:
	pass
