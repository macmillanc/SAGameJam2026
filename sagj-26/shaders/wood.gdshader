shader_type canvas_item;
render_mode blend_mix;

// --- Colors ---
uniform vec4 wood_base : source_color = vec4(0.55, 0.35, 0.20, 1.0);   
uniform vec4 wood_streak : source_color = vec4(0.40, 0.24, 0.12, 1.0); 

// --- Controls ---
uniform float streak_frequency : hint_range(1.0, 40.0) = 12.0; 
uniform float intensity : hint_range(0.0, 1.0) = 0.35;         
uniform float texture_scale : hint_range(0.1, 10.0) = 1.0;

// Bridge to transfer world coordinates from vertex to fragment
varying vec2 world_pos;

void vertex() {
	// Capture the exact world position so rotation/flips don't affect texture mapping
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// Use world position coordinates scaled down
	vec2 p = world_pos * 0.05 * texture_scale;

	// Create clean parallel wood grain streaks using world space
	float grain = sin(p.x * streak_frequency + (p.y * 3.0));
	grain = grain * 0.5 + 0.5; // Normalize to 0.0 - 1.0
	
	// Blend colors
	vec3 final_color = mix(wood_base.rgb, wood_streak.rgb, grain * intensity);
	
	// Respect sprite alpha mask (e.g., crate shapes)
	vec4 orig_tex = texture(TEXTURE, UV);
	if (orig_tex.a < 0.01) {
		discard;
	}

	COLOR = vec4(final_color, orig_tex.a);
}