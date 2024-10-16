extends CharacterBody2D


const JUMP_VELOCITY = -400.0

@export var patrol_speed: int = 30
@export var chase_speed: int = 100

@export var detection_range: float = 100
@export var attack_range: float = 30
@export var attack_damage: int = 10
@export var attack_cooldown: float = 2  # Time between attacks

var is_chasing: bool = false
var player = null
var facing_right: bool = false 
var can_attack: bool = true
var direction: String = "right"


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
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_chasing and player:
		chase_player()
	else:
		patrol()

	move_and_slide()
	animations.play("move_left")


func patrol() -> void:
	if not raycast.is_colliding() and is_on_floor():
		# Flip direction when reaching the edge
		facing_right = !facing_right
		scale.x = -scale.x
		velocity.x = patrol_speed if facing_right else -patrol_speed
	else:
		# Continue moving in the current direction
		velocity.x = patrol_speed if facing_right else -patrol_speed


func chase_player() -> void:
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
