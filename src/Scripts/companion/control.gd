extends Control

# Companion reference
var companion_node_path: String = ""
@onready var companion_robot = get_node(companion_node_path)

func _ready():
	# Hide the menu initially
	self.visible = false
	# Connect button actions
	$Move.connect("pressed", _on_move_pressed)
	$Distract.connect("pressed", _on_distract_pressed)

func show_menu(position: Vector2):
	# Position and show the menu
	self.position = position
	self.visible = true

func _on_move_pressed():
	companion_robot.move_to_position(self.position)
	self.hide()

func _on_distract_pressed():
	companion_robot.make_noise(self.position)
	self.hide()

func _on_place_trap_pressed():
	companion_robot.place_trap(self.position)
	self.hide()
