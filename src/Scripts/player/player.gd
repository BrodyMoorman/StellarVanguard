extends CharacterBody2D


@export var speed: int = 300.0
@export var jump_velocity: int = -400.0
@export var crouch_multiplier: float = 0.5
@onready var animations = $AnimatedSprite2D
@onready var health_bar = $ProgressBar



var health: float = 100
var max_health: float = 100
var dead: bool
var can_take_damage: bool = true
var direction: String = "right"
var speed_multiplier: float = 1.0
var is_crouching: bool = false

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
		
		
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed* speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	move_and_slide()
	updateAnimation()
