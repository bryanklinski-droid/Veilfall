shader_type canvas_item;

uniform vec4 dirt_a : source_color = vec4(0.22, 0.18, 0.14, 1.0);
uniform vec4 dirt_b : source_color = vec4(0.34, 0.27, 0.20, 1.0);
uniform vec4 stone : source_color = vec4(0.16, 0.15, 0.15, 1.0);
uniform float scale = 18.0;
uniform float pixel_grid = 96.0;

float hash(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 19.19);
	return fract(p.x * p.y);
}

vec2 snap_uv(vec2 uv) {
	return (floor(uv * pixel_grid) + 0.5) / pixel_grid;
}

void fragment() {
	vec2 uv = snap_uv(UV);
	vec2 large_cell = floor(uv * scale);
	vec2 small_cell = floor(uv * scale * 5.0);
	float broad = hash(large_cell);
	float grit = hash(small_cell + vec2(5.0, 9.0));
	float chip = hash(floor(uv * scale * 8.0) + vec2(17.0, 3.0));

	vec4 col = dirt_a;
	if (broad > 0.34) {
		col = mix(dirt_a, dirt_b, 0.52);
	}
	if (broad > 0.72) {
		col = dirt_b;
	}

	// Discrete stone chips and compressed dirt clusters create a tile-like JRPG road surface.
	if (grit > 0.88) {
		col.rgb = mix(col.rgb, stone.rgb, 0.64);
	}
	if (chip > 0.95) {
		col.rgb *= 0.84;
	}

	// Two soft-but-stepped wagon ruts run along the north/south road.
	float left_rut = step(abs(uv.x - 0.34), 0.025);
	float right_rut = step(abs(uv.x - 0.66), 0.025);
	col.rgb *= 1.0 - (left_rut + right_rut) * 0.07;

	COLOR = col;
}
