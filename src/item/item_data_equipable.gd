extends ItemData
class_name ItemDataEquipable

@export var heal_value:float = 15.0


func use(target,index) -> void:
	target._set_active_item(self, index)
