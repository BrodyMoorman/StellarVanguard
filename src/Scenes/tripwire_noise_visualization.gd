extends Control


var radius = 0.0

func set_radius(new_radius):
	radius = new_radius
	queue_redraw()  # Triggers _draw() in Node2D

func _draw():
	draw_circle(Vector2(0, 0), radius, Color(1, 1, 1, 0.05))  # Semi-transparent white
