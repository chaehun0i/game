shader_type canvas_item;

uniform vec4 jacket_color : source_color = vec4(0.85, 0.60, 0.19, 1.0);

void fragment() {
	vec4 texel = texture(TEXTURE, UV) * COLOR;
	vec3 source = texel.rgb;
	float golden = smoothstep(0.28, 0.54, source.r - source.g)
		* smoothstep(0.04, 0.16, source.g - source.b)
		* smoothstep(0.16, 0.34, source.g);
	texel.rgb = mix(source, source * jacket_color.rgb / vec3(0.85, 0.53, 0.12), golden * 0.92);
	COLOR = texel;
}
