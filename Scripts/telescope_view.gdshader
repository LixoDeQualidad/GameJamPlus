shader_type canvas_item;

uniform float radius : hint_range(0.05, 0.6) = 0.4;
uniform float softness : hint_range(0.0, 0.1) = 0.005;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	float d = length(uv);
	COLOR = vec4(0.0, 0.0, 0.0, smoothstep(radius, radius + softness, d));
}