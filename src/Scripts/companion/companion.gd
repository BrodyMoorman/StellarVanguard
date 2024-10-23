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
@onready var health_bar = $ProgressBar
@onready var sound_area = $SoundCollision/CollisionShape2D
@onready var left_attack_box: Area2D = $left_attack_box
@onready var left_attack_shape: CollisionShape2D = $left_attack_box/CollisionShape2D
@onready var right_attack_box: Area2D = $right_attack_box
@onready var right_attack_shape: CollisionShape2D = $right_attack_box/CollisionShape2D

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
var player_hidden:bool = false
var is_attacking: bool = false
var in_animation:  bool = false
var last_direction = 1
