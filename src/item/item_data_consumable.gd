extends ItemData
class_name ItemDataConsumable

@export var heal_value:float = 15.0

func use(target) -> void:
	if heal_value != 0:
		target.heal(heal_value)
