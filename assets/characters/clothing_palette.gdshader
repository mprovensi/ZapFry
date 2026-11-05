shader_type canvas_item;
uniform sampler2D clothing_mask : filter_linear, repeat_disable;
uniform float source_hue = 0.92;
uniform vec4 target_color : source_color = vec4(0.2, 0.6, 0.4, 1.0);

vec3 rgb_to_hsv(vec3 c) {
	vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 0.000001;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv_to_rgb(vec3 c) {
	vec3 p = abs(fract(c.xxx + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
	return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}
void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec3 hsv = rgb_to_hsv(original.rgb);
	float distance = abs(hsv.x - source_hue);
	distance = min(distance, 1.0 - distance);
	float weight = (1.0 - smoothstep(0.045, 0.07, distance));
	weight *= smoothstep(0.20, 0.32, hsv.y);
	// Osso, brilho ciano e reflexos metálicos ficam fora da recoloração.
	weight *= 1.0 - smoothstep(0.70, 0.82, hsv.z);
	weight *= texture(clothing_mask, UV).a;
	vec3 target = rgb_to_hsv(target_color.rgb);
	vec3 changed = hsv_to_rgb(vec3(target.x, clamp(hsv.y * target.y / 0.6, 0.0, 1.0), hsv.z));
	COLOR = vec4(mix(original.rgb, changed, weight), original.a);
}
