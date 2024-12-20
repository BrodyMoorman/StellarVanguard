extends Node2D

@onready var inventory_interface: Control = $UI/InventoryInterface
@onready var player: CharacterBody2D = $Player
@onready var hot_bar_inventory: PanelContainer = $UI/HotBarInventory
@onready var deployables: Node2D = $Deployables

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	hot_bar_inventory.set_inventory_data(player.inventory_data)

func get_deployables_node()-> Node:
	return deployables

func toggle_inventory_interface() -> void:
	inventory_interface.visible = not  inventory_interface.visible
	if inventory_interface.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		hot_bar_inventory.hide()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		hot_bar_inventory.show()	

		
