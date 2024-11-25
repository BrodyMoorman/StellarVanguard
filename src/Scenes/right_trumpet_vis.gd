extends Control


var points = PackedVector2Array([Vector2(0,-1),Vector2(0,1),Vector2(250,60),Vector2(250,-60)])
func _draw():
	draw_colored_polygon(points, Color(1, 1, 1, 0.05))
	
