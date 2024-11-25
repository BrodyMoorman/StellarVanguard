extends Node2D


var frequency: int = 0
var is_active: bool = false
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var fortnite: AudioStreamPlayer = $Fortnite
@onready var interaction_area: InteractionArea = $InteractionArea

const PickUp = preload("res://src/item/pickup/Pickup.tscn")
const BOOM_BOX = preload("res://src/item/items/boomBox.tres")
func activate() -> void:
	is_active = true
	animated_sprite_2d.animation = "playing"
	fortnite.play(0.2)
	collision_shape_2d.disabled = false
	
func deactivate()-> void:
	is_active = false
	animated_sprite_2d.animation ="default"
	fortnite.stop()
	collision_shape_2d.disabled = true
func toggle() -> void:
	if !is_active:
		activate()
	else:
		deactivate()

func _on_interact():
	deactivate()
	var dropSlotData: SlotData = SlotData.new()
	dropSlotData.item_data = BOOM_BOX
	dropSlotData.quantity = 1
	var pickup = PickUp.instantiate()
	pickup.slot_data = dropSlotData
	pickup.position = position
	get_parent().get_parent().add_child(pickup)
	queue_free()  # This will despawn the enemy
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.animation = "default"
	interaction_area.interact = Callable(self, "_on_interact")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_active and !fortnite.playing:
		fortnite.play(0.2)
