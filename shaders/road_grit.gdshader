shader_type canvas_item;

uniform vec4 dirt_a : source_color = vec4(0.22, 0.18, 0.14, 1.0);
uniform vec4 dirt_b : source_color = vec4(0.34, 0.27, 0.20, 1.0);
uniform vec4 stone : source_color = vec4(0.16, 0.15, 0.15, 1.0);
uniform float scale = 18.0;

float hash(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 19.19);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	float broad = noise(UV * scale * 0.62);
	float grit = noise(UV * scale * 3.4 + vec2(5.2, 8.7));
	float chip = noise(UV * scale * 8.0 + vec2(17.0, 3.0));

	vec4 col = mix(dirt_a, dirt_b, smoothstep(0.18, 0.86, broad));
	col.rgb *= 0.92 + grit * 0.14;

	float stone_mask = smoothstep(0.91, 0.975, chip);
	col.rgb = mix(col.rgb, stone.rgb, stone_mask * 0.48);

	// Soft compacted wagon ruts: visible on inspection, not thick drawn lines.
	float left_rut = 1.0 - smoothstep(0.018, 0.05, abs(UV.x - 0.34));
	float right_rut = 1.0 - smoothstep(0.018, 0.05, abs(UV.x - 0.66));
	col.rgb *= 1.0 - (left_rut + right_rut) * 0.045;

	COLOR = col;
}
