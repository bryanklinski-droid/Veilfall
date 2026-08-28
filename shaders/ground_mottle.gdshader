shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.055, 0.075, 0.062, 1.0);
uniform vec4 color_b : source_color = vec4(0.11, 0.145, 0.105, 1.0);
uniform vec4 detail_color : source_color = vec4(0.16, 0.12, 0.09, 1.0);
uniform float scale = 11.0;
uniform float pixel_grid = 96.0;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec2 snap_uv(vec2 uv) {
	return (floor(uv * pixel_grid) + 0.5) / pixel_grid;
}

void fragment() {
	vec2 uv = snap_uv(UV);
	vec2 cell = floor(uv * scale * 2.0);
	float broad = hash(floor(uv * scale));
	float fine = hash(cell + vec2(11.0, 7.0));
	float fleck = hash(floor(uv * scale * 7.0) + vec2(3.0, 17.0));

	vec4 col = color_a;
	if (broad > 0.42) {
		col = mix(color_a, color_b, 0.58);
	}
	if (broad > 0.72) {
		col = color_b;
	}

	// Small clustered blocks imitate hand-placed grass/soil pixels instead of smooth procedural noise.
	if (fine > 0.82) {
		col.rgb += vec3(0.015, 0.025, 0.012);
	}
	if (fleck > 0.94) {
		col.rgb = mix(col.rgb, detail_color.rgb, 0.26);
	}

	COLOR = col;
}
