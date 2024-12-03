extends CharacterBody2D

const JUMP_VELOCITY = -400.0

@export var patrol_speed: int = 30
@export var chase_speed: int = 150

@export var jump_velocity: float = -400.0
@export var max_jump_attempts: int = 3

@export var starting_health: int = 100

@export var detection_range: float = 60
@export var attack_range: float = 50
@export var attack_damage: int = 10
@export var attack_cooldown: float = 2 # Time between attacks

@export var noise_detection_range: float = 150.0
@export var noise_timeout: float = 0.1  # How long to wait at the last known location before resuming patrol

@export var max_echolocation_range: float = 50.0
@export var echolocation_expansion_speed: float = 100.0
@export var echolocation_cooldown: float = 3.0  # Cooldown between pulses

@onready var player = null
@onready var alert_indicator = $AlertIndicator
@onready var raycast = $RayCast2D
@onready var attack_area = $Area2D
@onready var animations = $AnimatedSprite2D

@onready var noise_visualization: Control = $NoiseVisualization
@onready var echolocation_area = $EcholocationArea
@onready var echolocation_shape: CircleShape2D = $EcholocationArea/CollisionShape2D.shape
@onready var echolocation_timer: Timer = Timer.new()
var is_echolocating: bool = false

var health: int = starting_health
var is_chasing: bool = false

var facing_right: bool = true 
var can_attack: bool = true
var attack_timer: float = 0.0

var direction: String = "right"

var knockback_force = 500
var knockback_duration = 0.2
var is_knocked_back = false
var knockback_velocity = Vector2.ZERO

var jump_attempts: int = 0
var is_jumping: bool = false


func _ready() -> void:
	echolocation_timer.wait_time = echolocation_cooldown
	echolocation_timer.one_shot = true
	echolocation_timer.connect("timeout", _on_echolocation_timeout)
	add_child(echolocation_timer)
	start_echolocation()

func _physics_process(delta: float) -> void:
	if is_knocked_back:
		velocity = knockback_velocity
	if health <= 0:
		die()
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor():
		is_jumping = false
	
	if not is_echolocating and not is_chasing:
		patrol()
		start_echolocation()
	
	if is_echolocating:
		expand_echolocation(delta)
	if is_chasing:
		if not can_attack:
			attack_timer += delta 
			if attack_timer >= attack_cooldown:
				can_attack = true
				attack_timer = 0.0
		chase_player()
	move_and_slide()
	

func start_echolocation() -> void:
	is_echolocating = true
	echolocation_shape.radius = 0  # Reset radius to start from zero
	noise_visualization.visible = true
	noise_visualization.set_radius(0)  # Reset visualization

func expand_echolocation(delta: float) -> void:
	if echolocation_shape.radius < max_echolocation_range-3:
	# Gradually expand the radius
		var expansion_factor = 1.0 - (echolocation_shape.radius / max_echolocation_range)
		var current_speed = echolocation_expansion_speed * expansion_factor
		echolocation_shape.radius += current_speed * delta
		noise_visualization.set_radius(echolocation_shape.radius)
	else:
	# Stop expanding and wait for cooldown
		is_echolocating = false
		noise_visualization.visible = false
		echolocation_timer.start()


func _on_echolocation_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		is_echolocating = false
		noise_visualization.visible = false
		player = area.get_parent()
		is_chasing = true
		chase_player()


func _on_echolocation_timeout() -> void:
	start_echolocation()


func die():
	queue_free()  # This will despawn the enemy
	
	
func patrol() -> void:
	if is_chasing:
		chase_player()
	if ((not raycast.is_colliding() and is_on_floor()) || velocity.x  == 0):
		# Flip direction when reaching the edge
		facing_right = !facing_right
		scale.x = -scale.x
		velocity.x = patrol_speed if facing_right else -patrol_speed
	else:
		# Continue moving in the current direction
		velocity.x = patrol_speed if facing_right else -patrol_speed
		
		
func chase_player() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() == 0:
		return
	
	player = players[0]
	var distance_squared = global_position.distance_squared_to(player.global_position)

	if distance_squared < detection_range * detection_range:
		var direction_to_player = sign(player.position.x - position.x)
		velocity.x = direction_to_player * chase_speed
		
		# Update facing direction
		var prev_face = facing_right
		facing_right = direction_to_player > 0
		if prev_face != facing_right:
			scale.x = -scale.x

		# Check attack range
		if distance_squared <= attack_range * attack_range and can_attack:
			print("Performing attack")
			perform_attack()
	else:
		print("Player lost")
		is_chasing = false
		player = null
		patrol()
			

func perform_attack() -> void:
	#play attack animation
	can_attack = false
	if player and player.is_in_group("player"):
		player.take_damage(attack_damage)
