shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.055, 0.075, 0.062, 1.0);
uniform vec4 color_b : source_color = vec4(0.11, 0.145, 0.105, 1.0);
uniform vec4 detail_color : source_color = vec4(0.16, 0.12, 0.09, 1.0);
uniform float scale = 11.0;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	float broad = noise(UV * scale);
	float mid = noise(UV * scale * 2.6 + vec2(4.7, 8.2));
	float fleck = noise(UV * scale * 8.5 + vec2(13.0, 3.0));

	vec4 col = mix(color_a, color_b, smoothstep(0.18, 0.86, broad));
	col.rgb *= 0.94 + mid * 0.11;

	// Sparse soil/leaf-litter flecks keep the surface lively without reading as giant pixels.
	float dirt_mask = smoothstep(0.90, 0.97, fleck);
	col.rgb = mix(col.rgb, detail_color.rgb, dirt_mask * 0.30);

	COLOR = col;
}
