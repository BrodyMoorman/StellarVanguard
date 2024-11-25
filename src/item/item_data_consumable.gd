extends ItemData
class_name ItemDataConsumable

@export var heal_value:float = 15.0

func use(target, index) -> void:
	if heal_value != 0:
		target.heal(heal_value)
	if name == "Alien Sheet Music":
		target.give_music_powers()
