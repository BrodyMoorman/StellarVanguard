extends Node2D

@onready var hitbox_area = $Hitbox/CollisionShape2D
@onready var sound_area = $SoundCollision/CollisionShape2D
@onready var noise_visualization: Control = $NoiseVisualization

signal player_triggered(noise_radius: float)

@export var base_noise_radius: float = 80.0
@export var max_noise_radius: float = 300.0
@export var noise_expand_speed: float = 150.0
@export var noise_reset_interval: float = 1.0  # Time in seconds to reset noise

var noise_active: bool = false
var current_noise_radius: float = 0.0
var player_inside: bool = false

func _ready() -> void:
	if noise_visualization:
		noise_visualization.visible = false
	if hitbox_area:
		print("Signal connection:", hitbox_area.is_connected("area_entered", _on_area_entered))


func _on_area_entered(area: Area2D):
	# Check if the entered area belongs to the Player
	print("Area Entered:")
	print("  Name:", area.name)
	print("  Parent:", area.get_parent())
	print("  Groups:", area.get_groups())
	if area.get_parent().is_in_group("Player"):
		print("Player entered tripwire!")
		player_inside = true
		if not noise_active:
			_start_noise()



func _on_area_exited(area: Area2D):
	print("Area exited:", area.name)
	if area.get_parent().is_in_group("Player"):
		print("Player exited tripwire!")
		player_inside = false
		noise_active = false
		noise_visualization.visible = false

func _start_noise():
	noise_active = true
	current_noise_radius = base_noise_radius
	noise_visualization.visible = true
	emit_signal("player_triggered", base_noise_radius)
	# Start resetting the noise periodically
	get_tree().create_timer(noise_reset_interval).connect("timeout", _reset_noise)

func _reset_noise():
	if player_inside:
		current_noise_radius = base_noise_radius
		emit_signal("player_triggered", base_noise_radius)
		# Restart the timer if the player is still inside
		get_tree().create_timer(noise_reset_interval).connect("timeout", _reset_noise)
	else:
		noise_active = false
		noise_visualization.visible = false

func _process(delta: float) -> void:
	if noise_active:
		# Expand the noise visualization
		current_noise_radius = min(current_noise_radius + noise_expand_speed * delta, max_noise_radius)
		noise_visualization.set_radius(current_noise_radius)
