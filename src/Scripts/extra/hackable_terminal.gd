extends Node2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var area_2d: Area2D = $Laser/Area2D
@onready var collision_shape_2d: CollisionShape2D = $Laser/Area2D/CollisionShape2D
@onready var power_down: AudioStreamPlayer = $AudioStreamPlayer2D/"Power-down"
@onready var power_up: AudioStreamPlayer = $AudioStreamPlayer2D/"Power-up"
@onready var zap: AudioStreamPlayer = $AudioStreamPlayer2D/Zap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interact():
	if !area_2d.visible:
		power_up.play()
	else:
		power_down.play()
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.get_parent().is_in_group("damageable")):
		area.get_parent().take_damage(1000)
		zap.play()


func _on_powerup_finished() -> void:
	area_2d.visible = true
	collision_shape_2d.disabled = false


func _on_powerdown_finished() -> void:
	area_2d.visible = false
	collision_shape_2d.disabled = true
