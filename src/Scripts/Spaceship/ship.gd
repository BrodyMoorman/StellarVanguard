extends CharacterBody2D

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var resistance := 2.0
@export var rotate_speed := 200.0

func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("ship_forward", "ship_back"))
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("ship_right"):
		rotate(deg_to_rad(rotate_speed * delta))
	
	elif Input.is_action_pressed("ship_left"):
		rotate(deg_to_rad(-rotate_speed * delta))
	
	else:
		pass
	
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, resistance)
	
	move_and_slide()
