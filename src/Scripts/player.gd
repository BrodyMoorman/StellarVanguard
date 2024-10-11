extends CharacterBody2D


@export var speed: int = 300.0
@export var jump_velocity: int = -400.0
@onready var animations = $AnimatedSprite2D

var health = 100
var max_health = 100
var min_health = 0
var dead: bool
var can_take_damage: bool
var direction = "right"

func updateAnimation():
	if velocity.length() == 0:
		animations.play("idle_" + direction)
	else:
		
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		animations.play("move_" + direction)
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)


	move_and_slide()
	updateAnimation()
