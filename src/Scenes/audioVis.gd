extends Control

var radius = 8

func set_radius(new_radius:float):
	radius = new_radius
	queue_redraw()


func _draw():
	
	draw_circle(Vector2(0, 0), radius, Color(1, 1, 1, 0.05))
