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
	float n = noise(UV * scale);
	float grit = noise(UV * scale * 4.0 + vec2(5.2, 8.7));
	vec4 col = mix(dirt_a, dirt_b, smoothstep(0.25, 0.8, n));
	float stones = smoothstep(0.88, 0.97, grit);
	col.rgb = mix(col.rgb, stone.rgb, stones * 0.65);
	float rut = smoothstep(0.45, 0.53, abs(UV.x - 0.32)) * smoothstep(0.45, 0.53, abs(UV.x - 0.68));
	col.rgb *= 0.90 + 0.10 * rut;
	COLOR = col;
}
