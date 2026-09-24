shader_type canvas_item;
render_mode blend_mix;

// Solid Industrial Grey Color (Adjustable in the Inspector)
uniform vec4 factory_color : source_color = vec4(0.35, 0.37, 0.40, 1.0);

// Subtle grit/grain so it doesn't look completely flat
uniform float micro_grain : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	// Discard transparent pixels OR a white background if your image has one
	if (tex.a < 0.01 || (tex.r > 0.95 && tex.g > 0.95 && tex.b > 0.95)) {
		discard;
	}

	vec3 final_color = factory_color.rgb;

	// Apply subtle gritty texture grain
	float grain = fract(sin(dot(UV * vec2(64.0), vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
	final_color += grain * micro_grain;

	COLOR = vec4(final_color, tex.a);
}