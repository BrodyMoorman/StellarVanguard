extends PanelContainer

@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer

const Slot = preload("res://src/inventory/slot.tscn")

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hotbar)
	populate_hotbar(inventory_data)
	
func populate_hotbar(inventory_data: InventoryData) -> void:
	for child in h_box_container.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slot_datas.slice(0,6):
		var slot = Slot.instantiate()
		h_box_container.add_child(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)
