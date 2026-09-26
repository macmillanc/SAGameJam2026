shader_type canvas_item;
render_mode blend_mix;

// --- Colors ---
uniform vec4 metal_base : source_color = vec4(0.45, 0.47, 0.50, 1.0);     // Base grey/silver metal
uniform vec4 metal_highlight : source_color = vec4(0.75, 0.78, 0.82, 1.0); // Bright metallic sheen
uniform vec4 brush_streak : source_color = vec4(0.30, 0.31, 0.33, 1.0);    // Darker brushed lines

// --- Controls ---
uniform float brush_frequency : hint_range(1.0, 100.0) = 45.0; 
uniform float brush_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float shine_frequency : hint_range(0.1, 10.0) = 1.2;
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

	// 1. Create fine, vertical brushed metal grain
	float brush = sin(p.x * brush_frequency);
	brush = brush * 0.5 + 0.5; // Normalize to 0.0 - 1.0

	// 2. Create broad metallic specular highlights (sheen plates) across world space
	float shine = sin(p.x * shine_frequency + p.y);
	shine = fract(shine * 2.0); // Create sharper, reflective metallic bands
	shine = smoothstep(0.3, 0.7, shine);

	// Blend the base metal with the brushed streaks
	vec3 mixed_metal = mix(metal_base.rgb, brush_streak.rgb, brush * brush_intensity);

	// Layer the bright specular highlights on top
	vec3 final_color = mix(mixed_metal, metal_highlight.rgb, shine * 0.4);
	
	// Respect sprite alpha mask (e.g., metal sheet shapes)
	vec4 orig_tex = texture(TEXTURE, UV);
	if (orig_tex.a < 0.01) {
		discard;
	}

	COLOR = vec4(final_color, orig_tex.a);
}
