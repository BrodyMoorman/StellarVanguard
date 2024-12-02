extends CharacterBody2D

signal transmit_frequency

const BoomBox = preload("res://src/deployables/boom_box.tscn")
const RF_RECIEVER = preload("res://src/deployables/rf_reciever.tscn")
const ALARM_CLOCK = preload("res://src/deployables/alarm_clock.tscn")

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
@onready var footstep_metal: AudioStreamPlayer = $AudioStreamPlayer2D/FootstepMetal
@onready var bad_trumpet_trimmed: AudioStreamPlayer = $BadTrumpetTrimmed
@onready var trumpet_right_collision: CollisionPolygon2D = $TrumpetRight/TrumpetRightCollision
@onready var trumpet_left_collision: CollisionPolygon2D = $TrumpetLeft/TrumpetLeftCollision
@onready var right_trumpet_vis: Control = $TrumpetRight/RightTrumpetVis
@onready var left_trumpet_vis: Control = $TrumpetLeft/LeftTrumpetVis
@onready var louis: AudioStreamPlayer = $Louis
@onready var freq_label: Label = $CanvasLayer/Control/FreqLabel
@onready var floor_detection: RayCast2D = $FloorDetection
@onready var radiobeep: AudioStreamPlayer = $Radiobeep
@onready var pauseMenu = $UI/Pause_Screen
@onready var respawn = $UI/Player_Death_Screen
#@onready var playButton: Button = find_node()


signal interact
signal toggle_inventory

#var world_node: Node = get_stack()

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
var inventory_open: bool = false
var active_item: String = ""
var is_playing_trumpet = false
var has_music_powers = false
var active_index: int
var current_frequency:int = 0
var deployables = []
var frames_since_on_floor:int = 0
var allow_jump:bool = true
var paused:bool = false


func _ready() -> void:
	add_to_group("Player")
	PlayerManager.player = self
	health_bar.value = health
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	

func _process(delta):
	if Input.is_action_just_pressed("pause_game"):
		if inventory_open:
			toggle_inventory.emit()
			inventory_open = !inventory_open			
		pauseGame()
	
	if Engine.time_scale != 0:
		paused = !paused
		pauseMenu.hide()


func updateAnimation() -> void:
	var idle = !velocity.x
	animation_tree.set("parameters/conditions/Attacking", is_attacking)
	animation_tree.set("parameters/conditions/Playing", is_playing_trumpet)
	animation_tree.set("parameters/conditions/Idle", (idle && !is_crouching))
	animation_tree.set("parameters/conditions/Walk", (!idle && !is_crouching))
	animation_tree.set("parameters/conditions/CrouchIdle", (idle && is_crouching))
	animation_tree.set("parameters/conditions/CrouchWalk", (!idle && is_crouching))

	
	animation_tree.set("parameters/Attack/blend_position", last_direction)
	animation_tree.set("parameters/CrouchIdle/blend_position", last_direction)
	animation_tree.set("parameters/CrouchWalking/blend_position", last_direction)
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)
	animation_tree.set("parameters/Trumpet/blend_position", last_direction)
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

func _set_active_item(item: ItemData, index):
	active_item = item.name
	active_index = index
	if inventory_data.slot_datas[active_index].item_data is ItemDataRemote:
		current_frequency = 1
		freq_label.text = "%sMHz" % current_frequency
		freq_label.show()
	else:
		freq_label.hide()

func increment_freq()->void:
	if current_frequency < 9:
		current_frequency+=1
	freq_label.text = "%sMHz" % current_frequency
	
func decrement_freq()->void:
	if current_frequency >= 2:
		current_frequency-=1
		freq_label.text = "%sMHz" % current_frequency

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
	Engine.time_scale = 0
	respawn.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func deploy_boombox()->void:
	var new_boombox = BoomBox.instantiate()
	new_boombox.frequency = current_frequency
	if floor_detection.is_colliding():
		var collision_point = floor_detection.get_collision_point()
		collision_point.y -= 5
		new_boombox.position = collision_point
	else:
		new_boombox.position = position
	var deployables_node = get_parent().get_deployables_node()
	deployables_node.add_child(new_boombox)
	active_item = ""
	inventory_data.slot_datas[active_index] = null
	active_index = -1
	inventory_data.updateInv()
func deploy_rf_reciever()->void:
	var new_rf = RF_RECIEVER.instantiate()
	new_rf.frequency = current_frequency
	if floor_detection.is_colliding():
		var collision_point = floor_detection.get_collision_point()
		collision_point.y -= 5
		new_rf.position = collision_point
	else:
		new_rf.position = position
	var deployables_node = get_parent().get_deployables_node()
	deployables_node.add_child(new_rf)
	active_item = ""
	inventory_data.slot_datas[active_index] = null
	active_index = -1
	inventory_data.updateInv()
func deploy_alarm_clock()-> void:
	var new_alarm = ALARM_CLOCK.instantiate()
	if floor_detection.is_colliding():
		var collision_point = floor_detection.get_collision_point()
		collision_point.y -= 5
		new_alarm.position = collision_point
	else:
		new_alarm.position = position
	var deployables_node = get_parent().get_deployables_node()
	deployables_node.add_child(new_alarm)
	active_item = ""
	inventory_data.slot_datas[active_index] = null
	active_index = -1
	inventory_data.updateInv()
	

func transmit_signal() -> void:
	radiobeep.play()
	for deployable in get_parent().get_deployables_node().get_children():
		if deployable.frequency == current_frequency:
			deployable.toggle()
		


func attack() -> void:
	is_attacking = true

func give_music_powers() -> void:
	has_music_powers = true

func start_playing_trumpet():
	is_playing_trumpet = true
	if(has_music_powers):
		if(!louis.playing):
			louis.play(1.0)
	else:
		if(!bad_trumpet_trimmed.playing):
			bad_trumpet_trimmed.play()
	
func stop_playing_trumpet():
	is_playing_trumpet = false
	bad_trumpet_trimmed.stop()
	louis.stop()
	trumpet_right_collision.disabled = true
	trumpet_left_collision.disabled = true
	right_trumpet_vis.visible = false
	left_trumpet_vis.visible = false

func heal(heal_value: float) -> void:
	if health + heal_value > 100.0:
		health = 100.0
	else:
		health += heal_value
	health_bar.value = health

func _play_footstep_audio(volume:int = -17) -> void:
	if(volume != -17):
		footstep_metal.pitch_scale = randf_range(0.9, 1.1)
		footstep_metal.volume_db = volume
		footstep_metal.play()
	else:
		if is_on_floor():
			footstep_metal.pitch_scale = randf_range(0.9, 1.1)
			if(is_crouching):
				footstep_metal.volume_db = -25
			else:
				footstep_metal.volume_db = -17
			footstep_metal.play()


func _physics_process(delta: float) -> void:
	if dead: return
	
	if is_on_floor():
		frames_since_on_floor= 0
		allow_jump = true
	else:
		frames_since_on_floor+=1
		if frames_since_on_floor > 10:
			allow_jump = false
	
	# Add the gravity.
	if not is_on_floor() && !player_hidden:
		velocity += get_gravity() * delta
		was_falling = true
		falling_speed = velocity.y
		
	if is_playing_trumpet:
		if last_direction > 0:
			trumpet_right_collision.disabled = false
			trumpet_left_collision.disabled = true
			right_trumpet_vis.visible = true
			left_trumpet_vis.visible = false
		else:
			trumpet_right_collision.disabled = true
			trumpet_left_collision.disabled = false
			right_trumpet_vis.visible = false
			left_trumpet_vis.visible = true


	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and allow_jump:
		if(!player_hidden):
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
		if(!inventory_open):
			if(!player_hidden):
				if(active_item == "Actual wrench"):
					attack()
				if(active_item == "Boom Box"):
					deploy_boombox()
				if(active_item=="RF Reciever"):
					deploy_rf_reciever()
				if(active_item=="Alarm Clock"):
					deploy_alarm_clock()
			if(active_item == "RF Transmitter"):
				transmit_signal()
			
	
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
		inventory_open = !inventory_open

	
	if Input.is_action_pressed("attack"):
		if(!player_hidden && !inventory_open):
			if(active_item == "Trumpet"):
				start_playing_trumpet()
	
	if Input.is_action_just_released("attack"):
		if(active_item == "Trumpet"):
			stop_playing_trumpet()
	if Input.is_action_just_pressed("increment_freq"):
		if inventory_data.slot_datas[active_index] && inventory_data.slot_datas[active_index].item_data is ItemDataRemote:
			increment_freq()
			
			

	if Input.is_action_just_pressed("decrement_freq"):
		if inventory_data.slot_datas[active_index] && inventory_data.slot_datas[active_index].item_data is ItemDataRemote:
			decrement_freq()
			

	
		
		
		
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
			_play_footstep_audio(-10)
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

# for when the player wants to pause or exit the game
func pauseGame():
	paused = !paused
	pauseMenu.show()
	Engine.time_scale = 0
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func respawnScreen():
	respawn.show()
