shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.20, 0.07, 0.24, 1.0);
uniform vec4 vein_color : source_color = vec4(0.54, 0.12, 0.62, 1.0);
uniform float pulse_speed : hint_range(0.1, 5.0) = 1.2;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.22;
uniform float edge_softness : hint_range(0.01, 0.5) = 0.12;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	float n = noise(UV * 8.0 + vec2(TIME * 0.08, -TIME * 0.05));
	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed + n * 6.28318);
	float veins = smoothstep(0.56, 0.78, n + pulse * 0.12);
	vec4 color = mix(base_color, vein_color, veins * (0.45 + pulse * pulse_strength));
	color.rgb *= 0.88 + pulse * 0.16;
	COLOR = color;
}
