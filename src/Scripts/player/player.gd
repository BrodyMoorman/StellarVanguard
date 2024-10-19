extends CharacterBody2D


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

signal interact


var health: float = 100
var max_health: float = 100
var dead: bool
var can_take_damage: bool = true
var direction: String = "right"
var speed_multiplier: float = 1.0
var is_crouching: bool = false
var was_falling: bool = false
var falling_speed: float


func _ready() -> void:
	add_to_group("Player")


func updateAnimation() -> void:
	if velocity.length() == 0:
		if is_crouching:
			animations.play("idle_" + direction + "_crouch")
		else:
			animations.play("idle_" + direction)
	else:
		
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		
		if is_crouching:
			animations.play("move_" + direction + "_crouch")
		else:
			animations.play("move_" + direction)
	

func take_damage(damage: int) -> void:
		if can_take_damage and not dead:
			health -= damage
			if health <= 0:
				health = 0
				health_bar.value = health
				die()
			health_bar.value = health


func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	animations.play("death")
	# this is where we'll show the UI for respawn and etc


func _physics_process(delta: float) -> void:
	if dead: return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		was_falling = true
		falling_speed = velocity.y

	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("crouch"):
		speed_multiplier = crouch_multiplier
		is_crouching = true
	if Input.is_action_just_released("crouch"):
		speed_multiplier = 1.0
		is_crouching = false
		
	if Input.is_action_just_pressed("interact"):
		interact.emit()
		
		
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed* speed_multiplier
		if(is_crouching):
			sound_area.shape.set_radius(crouching_sound_radius)
		else:
			sound_area.shape.set_radius(walking_sound_radius)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		sound_area.shape.set_radius(8)
	if (was_falling && is_on_floor()):
		sound_area.shape.set_radius(clamp((falling_speed* fall_landing_radius_factor),min_landing_radius,max_landing_radius))
		was_falling= false
		falling_speed = 0.0
	move_and_slide()
	updateAnimation()
