extends Node2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var animations = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interact():
	print("Player Interacting")
	if(animations.animation == "default"):
		player.hide_player()
		animations.play("in_vent")
		interaction_area.action_name = "exit"
	else:
		animations.play("default")
		player.unhide_player()
		interaction_area.action_name = "enter"
	
