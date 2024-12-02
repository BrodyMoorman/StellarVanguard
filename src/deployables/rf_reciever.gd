extends Node2D
@onready var interaction_area: InteractionArea = $InteractionArea

const PickUp = preload("res://src/item/pickup/Pickup.tscn")
const RF_RECIEVER = preload("res://src/item/items/rfReciever.tres")
@onready var hacking_area: Area2D = $HackingArea

var frequency: int = 0
var is_active: bool = false

func activate() -> void:
	var terminals = hacking_area.get_overlapping_areas()
	for terminal in terminals:
		terminal.get_parent()._on_interact()
	

func toggle() -> void:
		activate()


func _on_pickup() -> void:
	var dropSlotData: SlotData = SlotData.new()
	dropSlotData.item_data = RF_RECIEVER
	dropSlotData.quantity = 1
	var pickup = PickUp.instantiate()
	pickup.slot_data = dropSlotData
	pickup.position = position
	get_parent().get_parent().add_child(pickup)
	queue_free()  # This will despawn the enemy
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_pickup")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
