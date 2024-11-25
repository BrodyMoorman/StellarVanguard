extends Node2D
@onready var ticking_player: AudioStreamPlayer2D = $TickingPlayer
@onready var ringing_player: AudioStreamPlayer2D = $RingingPlayer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ticking_player.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ticking_player_finished() -> void:
	ringing_player.play()
	collision_shape_2d.disabled= false



func _on_ringing_player_finished() -> void:
	queue_free()
