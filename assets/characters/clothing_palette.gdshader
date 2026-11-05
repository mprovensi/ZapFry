shader_type canvas_item;
uniform sampler2D clothing_mask : filter_linear, repeat_disable;
uniform float source_hue = 0.92;
uniform vec4 target_color : source_color = vec4(0.2, 0.6, 0.4, 1.0);
uniform bool recolor = false;
uniform vec4 face_region = vec4(0.0);
uniform vec2 head_offset = vec2(0.0);
uniform vec4 left_eye = vec4(0.0);
uniform vec4 right_eye = vec4(0.0);
uniform float blink = 0.0;
uniform sampler2D next_pose : source_color, filter_linear, repeat_disable;
uniform float pose_blend = 0.0;

vec4 close_eye(vec4 original, vec2 uv, vec4 region, vec3 skin) {
	if (region.z > 0.0 && region.w > 0.0 && blink > 0.0) {
		vec2 center = region.xy + region.zw * 0.5;
		vec2 local = (uv - center) / (region.zw * 0.5);
		float mask = (1.0 - smoothstep(0.80, 1.0, dot(local, local))) * blink;
		float curve = 0.08 + local.x * local.x * 0.25;
		float crease = 1.0 - smoothstep(0.08, 0.22, abs(local.y - curve));
		vec3 eyelid = mix(skin, skin * 0.22, crease);
		original.rgb = mix(original.rgb, eyelid, mask);
	}
	return original;
}

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
	vec2 uv = UV;
	if (face_region.z > 0.0 && face_region.w > 0.0) {
		vec2 local = (UV - face_region.xy) / face_region.zw;
		vec2 edges = smoothstep(vec2(0.0), vec2(0.18), local) * (vec2(1.0) - smoothstep(vec2(0.82), vec2(1.0), local));
		uv -= head_offset * edges.x * edges.y;
	}
	vec4 original = texture(TEXTURE, uv);
	if (pose_blend > 0.0) {
		vec4 next = texture(next_pose, uv);
		// Mistura em alpha pré-multiplicado evita halos nas bordas transparentes.
		float alpha = mix(original.a, next.a, pose_blend);
		vec3 rgb = mix(original.rgb * original.a, next.rgb * next.a, pose_blend);
		original = vec4(rgb / max(alpha, 0.000001), alpha);
	}
	if (blink > 0.0) {
		vec3 left_skin = texture(TEXTURE, vec2(left_eye.x + left_eye.z * 0.5, left_eye.y - left_eye.w * 0.3)).rgb;
		vec3 right_skin = texture(TEXTURE, vec2(right_eye.x + right_eye.z * 0.5, right_eye.y - right_eye.w * 0.3)).rgb;
		original = close_eye(close_eye(original, uv, left_eye, left_skin), uv, right_eye, right_skin);
	}
	vec3 hsv = rgb_to_hsv(original.rgb);
	float distance = abs(hsv.x - source_hue);
	distance = min(distance, 1.0 - distance);
	float weight = (1.0 - smoothstep(0.045, 0.07, distance));
	weight *= smoothstep(0.20, 0.32, hsv.y);
	// Osso, brilho ciano e reflexos metálicos ficam fora da recoloração.
	weight *= 1.0 - smoothstep(0.70, 0.82, hsv.z);
	weight *= texture(clothing_mask, uv).a * float(recolor);
	vec3 target = rgb_to_hsv(target_color.rgb);
	vec3 changed = hsv_to_rgb(vec3(target.x, clamp(hsv.y * target.y / 0.6, 0.0, 1.0), hsv.z));
	COLOR = vec4(mix(original.rgb, changed, weight), original.a);
}
