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
	float n1 = noise(UV * scale);
	float n2 = noise(UV * scale * 3.7 + vec2(7.3, 2.1));
	vec4 col = mix(color_a, color_b, smoothstep(0.22, 0.82, n1));
	float flecks = smoothstep(0.82, 0.96, n2);
	col.rgb = mix(col.rgb, detail_color.rgb, flecks * 0.35);
	COLOR = col;
}
