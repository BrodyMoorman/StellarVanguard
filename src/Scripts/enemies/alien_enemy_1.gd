extends CharacterBody2D


var speed = -30.0
const JUMP_VELOCITY = -400.0

var facing_right: bool = false 



func _physics_process(delta: float) -> void:
	# This function handles gravity and having the enemy move left at the start
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if !$RayCast2D.is_colliding() && is_on_floor():
		flip()

	velocity.x = speed
	
	move_and_slide()

func flip() -> void:
	# this function will flip the enemy to move the opposite direction when it
	# reaches the end of its basic patrol
	facing_right = !facing_right
	scale.x = -1 * abs(scale.x) 
	if facing_right:
		speed = abs(speed)
	else: 
		speed = -1 * abs(speed)
		

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.get_parent().is_in_group("Player"):
		# add the attack animation here
		# $AnimationPlayer.play("attack") 
		area.get_parent().queue_free()  # placeholding for doing damage, this just kills the player immediately
		# var player = area.get_parent()
		# player.take_damage(10) # have the player take some damage
