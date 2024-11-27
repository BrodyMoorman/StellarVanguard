extends CharacterBody2D

const PickUp = preload("res://src/item/pickup/Pickup.tscn")
const alienMatterItemData = preload("res://src/item/items/alienMatter.tres")
const JUMP_VELOCITY = -400.0

@export var patrol_speed: int = 30
@export var chase_speed: int = 150
@export var jump_velocity: float = -450.0
@export var max_jump_attempts: int = 3
@export var starting_health: int = 100
@export var detection_range: float = 50
@export var attack_range: float = 30
@export var attack_damage: int = 10
@export var attack_cooldown: float = 2  # Time between attacks
@export var noise_detection_range: float = 150.0
@export var noise_timeout: float = 3.0  # How long to wait at the last known location before resuming patrol

@onready var player = null

var health: int = starting_health
var is_chasing: bool = false

var facing_right: bool = false 
var can_attack: bool = true
var direction: String = "right"

var knockback_force = 500
var knockback_duration = 0.2
var is_knocked_back = false
var knockback_velocity = Vector2.ZERO

var last_known_player_position: Vector2 = Vector2.ZERO
var is_investigating_noise: bool = false
var noise_timer: Timer
var reached_location: bool = false  #flag to track if the location has been reached


var jump_attempts: int = 0
var is_jumping: bool = false

@onready var question_indicator: Label = $QuestionIndicator
@onready var alert_indicator = $AlertIndicator
@onready var raycast = $RayCast2D
@onready var attack_area = $Area2D
@onready var  animations = $AnimatedSprite2D
#@onready var animation_player = 

func _ready() -> void:
	noise_timer = Timer.new()
	noise_timer.wait_time = noise_timeout
	noise_timer.one_shot = true
	noise_timer.connect("timeout", Callable(self, "_on_noise_timer_timeout"))
	add_child(noise_timer)


func apply_knockback(direction: Vector2) -> void:
	knockback_velocity = direction.normalized() * knockback_force
	is_knocked_back = true
	await get_tree().create_timer(knockback_duration).timeout
	is_knocked_back = false
	knockback_velocity = Vector2.ZERO



func updateAnimation() -> void:
	if velocity.length() == 0:
		animations.play("idle_" + direction)
	else:
		
		if facing_right: animations.play("move_right")
		else: animations.play("move_left")
		

func _physics_process(delta: float) -> void:

	if is_knocked_back:
		velocity = knockback_velocity  
	if health <= 0:
		die()
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		is_jumping = false  # Reset jumping state when on the floor
# Setting velocity for CharacterBody2D
	if is_investigating_noise:
		investigate_noise()
		alert_indicator.visible = true
	else:
		patrol()
		alert_indicator.visible = false

	move_and_slide()
	animations.play("move_left")

func take_damage(damage:int = 50):
	health -= damage
	var knockback_direction = global_transform.origin - player.global_transform.origin

	apply_knockback(knockback_direction)

func die():
	print("Enemy killed")
	var dropSlotData: SlotData = SlotData.new()
	dropSlotData.item_data = alienMatterItemData
	dropSlotData.quantity = randi_range(1, 2)
	var pickup = PickUp.instantiate()
	pickup.slot_data = dropSlotData
	pickup.position = position
	get_parent().add_child(pickup)
	queue_free()  # This will despawn the enemy


func patrol() -> void:
	if ((not raycast.is_colliding() and is_on_floor()) || velocity.x  == 0):
		# Flip direction when reaching the edge
		facing_right = !facing_right
		scale.x = -scale.x
		velocity.x = patrol_speed if facing_right else -patrol_speed
	else:
		# Continue moving in the current direction
		velocity.x = patrol_speed if facing_right else -patrol_speed


func chase_player() -> void:
	#todo: Make sure it flips direction at walls or can jump, as necessary
	if player:
			
		if global_position.distance_to(player.global_position) <= attack_range and can_attack:
			perform_attack()
		if global_position.distance_to(player.global_position) > detection_range:
			is_chasing = false
			
	
	
func perform_attack() -> void:
	print("performing attack")
	#play attack animation
	can_attack = false
	if player and player.is_in_group("player"):
		player.take_damage(attack_damage)
	await(get_tree().create_timer(attack_cooldown))
	can_attack = true
	
func investigate_noise() -> void:
	if not reached_location:  # Only move toward the location if it hasn't been reached
		if position.distance_to(last_known_player_position) > 10:  # Some threshold for stopping
			var direction_to_location = (last_known_player_position - position).normalized()
			if (last_known_player_position.x < position.x && facing_right):
				facing_right = !facing_right
				scale.x = -scale.x
			if (last_known_player_position.x > position.x && !facing_right):
				facing_right = !facing_right
				scale.x = -scale.x
			
			velocity.x = direction_to_location.x * chase_speed
			if not is_on_floor():
				velocity += get_gravity() * get_physics_process_delta_time()
			
				
			if (is_on_wall() or !raycast.is_colliding()) and is_on_floor() and !is_jumping:
				print("trying jump")
				if jump_attempts < max_jump_attempts:
					jump()  # Try jumping over the wall
				else:
					# Too many jump attempts, go back to patrol
					is_investigating_noise = false
					patrol()
		
		else:
			
			 # Player not found, start the timer to resume patrol
			print("Reached location, starting timer to reset to patrol")
			reached_location = true  # Set flag to prevent rechecking
			velocity = Vector2.ZERO  # Stop movement
			noise_timer.start()  # Start the timer when enemy reaches the location

func jump() -> void:
	velocity.y = jump_velocity  # Apply jump velocity
	jump_attempts += 1
	is_jumping = true

func _on_noise_timer_timeout() -> void:
	print("Timer finished, returning to patrol")
	is_investigating_noise = false  # Resume patrolling when timer finishes
	reached_location  = false
	patrol()
	
func flip_sprite_based_on_velocity() -> void:
	if velocity.x > 0:
		scale.x = abs(scale.x)  # Face right (positive x velocity)
	elif velocity.x < 0:
		scale.x = -abs(scale.x)  # Face left (negative x velocity)



func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Somethings Here")
	print("Player detected")
	is_chasing = true
	player = area.get_parent()
	last_known_player_position = player.global_position
	is_investigating_noise = true
	reached_location =  false
	jump_attempts = 0  # Reset jump attempts
