shader_type canvas_item;

uniform vec2 center; // Center of the circle
uniform float radius = 50.0; // Radius of the circle
uniform float brightness = 1.5; // Brightness multiplier

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 pos = SCREEN_UV * vec2(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y);
    float dist = distance(pos, center);

    // Check if pixel is inside the circle radius
    if (dist < radius) {
        COLOR.rgb *= brightness; // Brighten the color
    }
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
