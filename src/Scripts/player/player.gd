extends CharacterBody2D

@export var inventory_data: InventoryData

@export var speed: int = 300.0
@export var jump_velocity: int = -400.0
@export var crouch_multiplier: float = 0.5
@export_group("Sound Radius Generation")
@export var walking_sound_radius: float = 80.0
@export var crouching_sound_radius: float = 20.0
@export var fall_landing_radius_factor: float  = 0.2
@export var max_landing_radius: float = 300.0
@export var min_landing_radius: float = 1.0
@onready var animations = $AnimatedSprite2D
@onready var health_bar = $ProgressBar
@onready var sound_area = $SoundCollision/CollisionShape2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var noise_visualization: Control = $NoiseVisualization
@onready var left_attack_box: Area2D = $left_attack_box
@onready var left_attack_shape: CollisionShape2D = $left_attack_box/CollisionShape2D
@onready var right_attack_box: Area2D = $right_attack_box
@onready var right_attack_shape: CollisionShape2D = $right_attack_box/CollisionShape2D

signal interact
signal toggle_inventory


var health: float = 50
var max_health: float = 100
var dead: bool
var can_take_damage: bool = true
var direction: String = "right"
var speed_multiplier: float = 1.0
var is_crouching: bool = false
var was_falling: bool = false
var falling_speed: float
var player_hidden:bool = false
var is_attacking: bool = false
var in_animation:  bool = false
var last_direction = 1



func _ready() -> void:
	add_to_group("Player")
	PlayerManager.player = self
	health_bar.value = health
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	

func updateAnimation() -> void:
	var idle = !velocity.x
	animation_tree.set("parameters/conditions/Attacking", is_attacking)
	animation_tree.set("parameters/conditions/Idle", (idle && !is_crouching))
	animation_tree.set("parameters/conditions/Walk", (!idle && !is_crouching))
	animation_tree.set("parameters/conditions/CrouchIdle", (idle && is_crouching))
	animation_tree.set("parameters/conditions/CrouchWalk", (!idle && is_crouching))

	
	animation_tree.set("parameters/Attack/blend_position", last_direction)
	animation_tree.set("parameters/CrouchIdle/blend_position", last_direction)
	animation_tree.set("parameters/CrouchWalking/blend_position", last_direction)
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)
	var normalized

func take_damage(damage: int) -> void:
	if player_hidden:
		pass
	if can_take_damage and not dead:
		health -= damage
		if health <= 0:
			health = 0
			health_bar.value = health
			die()
		health_bar.value = health

func hide_player():
	velocity.x = 0
	velocity.y = 0
	hide()
	player_hidden=true
	print(get_collision_mask())
	set_collision_mask_value(30, false)
	# Disable all collision shapes
	$SoundCollision/CollisionShape2D.disabled = true
	$NearCollision/CollisionShape2D.disabled = true
	
func unhide_player():
	show()
	player_hidden=false
	set_collision_mask_value(30, true)
	$SoundCollision/CollisionShape2D.disabled = false
	$NearCollision/CollisionShape2D.disabled = false
	
	
func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	animations.play("death")
	# this is where we'll show the UI for respawn and etc


func attack() -> void:
	is_attacking = true

func heal(heal_value: float) -> void:
	if health + heal_value > 100.0:
		health = 100.0
	else:
		health += heal_value
	health_bar.value = health


func _physics_process(delta: float) -> void:
	if dead: return
	
	# Add the gravity.
	if not is_on_floor() && !player_hidden:
		velocity += get_gravity() * delta
		was_falling = true
		falling_speed = velocity.y

	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("crouch"):
		if(!player_hidden):
			speed_multiplier = crouch_multiplier
			is_crouching = true
	if Input.is_action_just_released("crouch"):
		if(!player_hidden):
			speed_multiplier = 1.0
			is_crouching = false
		
	if Input.is_action_just_pressed("interact"):
		interact.emit()

	if Input.is_action_just_pressed("attack"):
		if(!player_hidden):
			attack()
	
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
		
		
		
	var direction := Input.get_axis("move_left", "move_right")
	if(!player_hidden):
		if direction:
			last_direction = direction
			velocity.x = direction * speed* speed_multiplier
			if(is_crouching):
				sound_area.shape.set_radius(crouching_sound_radius)
			else:
				sound_area.shape.set_radius(walking_sound_radius)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			sound_area.shape.set_radius(move_toward(sound_area.shape.radius, 8, 5))
		if (was_falling && is_on_floor()):
			if(!is_crouching):
				sound_area.shape.set_radius(clamp((falling_speed* fall_landing_radius_factor),min_landing_radius,max_landing_radius))
			else:
				sound_area.shape.set_radius(clamp(((falling_speed* fall_landing_radius_factor)*0.5),min_landing_radius,max_landing_radius))
			was_falling= false
			falling_speed = 0.0
		noise_visualization.set_radius(sound_area.shape.radius)
	move_and_slide()
	updateAnimation()

	
	


func _on_animated_sprite_2d_animation_finished() -> void:
	in_animation = false


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "attack_left" || anim_name =="attack_right"):
		is_attacking = false
		right_attack_shape.disabled = true
		left_attack_shape.disabled = true


func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if(anim_name == "attack_left"):
		left_attack_shape.disabled = false
	if(anim_name=="attack_right"):
		right_attack_shape.disabled = false
		


func _on_right_attack_box_area_entered(area: Area2D) -> void:
	if(area.get_parent().is_in_group("damageable")):
		area.get_parent().take_damage()


func _on_left_attack_box_area_entered(area: Area2D) -> void:
	if(area.get_parent().is_in_group("damageable")):
		area.get_parent().take_damage()
