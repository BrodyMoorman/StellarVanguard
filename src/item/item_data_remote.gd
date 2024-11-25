extends ItemDataEquipable
class_name ItemDataRemote

var frequency: int

func use(target, index)  -> void:
	target._set_active_item(self, index)
	
