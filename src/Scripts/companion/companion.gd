extends CharacterBody2D

@export var speed: int = 250
@export var jump_velocity: int = -300
@export var walking_sound_radius: float = 60.0
@export var max_health: float = 100
@onready var animations = $AnimatedSprite2D
@onready var health_bar = $ProgressBar
@onready var sound_area = $SoundCollision/CollisionShape2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var noise_visualization: Control = $NoiseVisualization
@onready var left_attack_box: Area2D = $left_attack_box
@onready var left_attack_shape: CollisionShape2D = $left_attack_box/CollisionShape2D
@onready var right_attack_box: Area2D = $right_attack_box
@onready var right_attack_shape: CollisionShape2D = $right_attack_box/CollisionShape2D

var health: float = max_health
var dead: bool = false
var can_take_damage: bool = true
var last_direction: int = 1
var direction: Vector2 = Vector2.ZERO  # Fixed to use Vector2

signal move_ordered(target_position: Vector2)
signal make_noise
signal place_trap

func _ready() -> void:
	add_to_group("Companion")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	health = max_health

func updateAnimation() -> void:
	var idle = !velocity.x
	animation_tree.set("parameters/conditions/Idle", idle)
	animation_tree.set("parameters/conditions/Walk", !idle)
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)

func move_to_position(target_position: Vector2) -> void:
	# Move to a specified position
	direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	updateAnimation()

func make_noise_here(radius: float) -> void:
	sound_area.shape.set_radius(radius)
	emit_signal("make_noise")

func place_trap_here() -> void:
	# Logic for placing a trap; this is where you could instantiate a trap object if needed.
	emit_signal("place_trap")

func take_damage(damage: int) -> void:
	if can_take_damage and not dead:
		health -= damage
		health = max(health, 0)
		health_bar.value = health
		if health <= 0:
			die()

func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	animations.play("death")
	# Additional death logic, e.g., removing companion or setting respawn

func _physics_process(delta: float) -> void:
	if dead:
		return

	if direction.length() > 0:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta)  # Fixed to match move_toward signature

	# Update sound radius visualization if moving
	if velocity.x != 0:
		sound_area.shape.set_radius(walking_sound_radius)
		noise_visualization.set_radius(sound_area.shape.radius)

	move_and_slide()
	updateAnimation()

func _on_animated_sprite_2d_animation_finished() -> void:
	# Reset any one-time animations if needed
	pass

func _on_right_attack_box_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("damageable"):
		area.get_parent().take_damage()

func _on_left_attack_box_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("damageable"):
		area.get_parent().take_damage()
