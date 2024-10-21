extends CharacterBody2D


const JUMP_VELOCITY = -400.0

@export var patrol_speed: int = 30
@export var chase_speed: int = 100
@export var starting_health: int = 100
@export var detection_range: float = 50
@export var attack_range: float = 30
@export var attack_damage: int = 10
@export var attack_cooldown: float = 2  # Time between attacks
@onready var cooldown_timer = $CooldownTimer

var health: int = starting_health
var is_chasing: bool = false
var player = null
var facing_right: bool = false 
var can_attack: bool = true
var direction: String = "right"
var jump_target_position = Vector2()
var jump_velocity = Vector2()
var gravity =  800.0
var jump_in_progress = false
var jump_speed = 300.0
var jump_height = -500.0
var cooldown_time = 5.0  # 5-second cooldown



@onready var raycast = $RayCast2D
@onready var attack_area = $Area2D
@onready var  animations = $AnimatedSprite2D
#@onready var animation_player = 

func updateAnimation() -> void:
	if velocity.length() == 0:
		animations.play("idle_" + direction)
	else:
		
		if facing_right: animations.play("move_right")
		else: animations.play("move_left")
		

func _physics_process(delta: float) -> void:
	if(health <= 0):
		die()
	if jump_in_progress:
		# Apply gravity for the parabolic arc
		velocity.y += gravity * delta
		# Move the enemy based on velocity
		# Check if the enemy reached the target
		if position.distance_to(jump_target_position) < 10:
			jump_in_progress = false
			perform_attack()
	else:
		patrol()

	move_and_slide()
	animations.play("move_left")

func take_damage():
	health -= 50

func die():
	print("Enemy killed")
	queue_free()  # This will despawn the enemy


func patrol() -> void:
	if not raycast.is_colliding() and is_on_floor() and !jump_in_progress:
		# Flip direction when reaching the edge
		facing_right = !facing_right
		scale.x = -scale.x
		velocity.x = patrol_speed if facing_right else -patrol_speed
	else:
		# Continue moving in the current direction
		velocity.x = patrol_speed if facing_right else -patrol_speed

func mark_player_position():
	if player:
		jump_target_position = player.position
		jump_in_progress = true
		
		# Calculate horizontal velocity toward the target
		var distance = jump_target_position.x - position.x
		var time_to_reach_target = distance / jump_speed
		jump_velocity.x = jump_speed  # Constant horizontal speed
		
		# Calculate initial upward velocity for a smooth arc
		jump_velocity.y = (jump_height / time_to_reach_target)
		print("Player detected, starting jump to:", jump_target_position)

		# Start cooldown to prevent further attacks
		can_attack = false
		cooldown_timer.start(cooldown_time)  # Start cooldown timer

func chase_player() -> void:
	#todo: Make sure it flips direction at walls or can jump, as necessary
	if player:
		var direction_to_player = sign(player.position.x - position.x)
		velocity.x = direction_to_player * chase_speed
		
		if direction_to_player > 0:
			facing_right = true
		else:
			facing_right = false
			
		if global_position.distance_to(player.global_position) <= attack_range and can_attack:
			perform_attack()
		if global_position.distance_to(player.global_position) > detection_range:
			is_chasing = false
			player = null
	
	
func perform_attack() -> void:
	#play attack animation
	can_attack = false
	if player and player.is_in_group("Player"):
		player.take_damage(attack_damage)
	await(get_tree().create_timer(attack_cooldown))
	can_attack = true
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Somethings Here")
	if area.get_parent().is_in_group("Player"):
		print("Player detected")
		is_chasing = true
		player = area.get_parent()
		mark_player_position()
