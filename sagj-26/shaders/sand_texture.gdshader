shader_type canvas_item;

// Target shades to detect on your original dirt texture
uniform vec4 target_color_1 : source_color = vec4(0.47, 0.35, 0.24, 1.0); // Medium dirt brown
uniform vec4 target_color_2 : source_color = vec4(0.33, 0.24, 0.16, 1.0); // Dark dirt brown
uniform vec4 target_color_3 : source_color = vec4(0.60, 0.48, 0.36, 1.0); // Light dirt highlights

// Replacement colors for the sand look
uniform vec4 sand_color_1 : source_color = vec4(0.88, 0.79, 0.59, 1.0);   // Main sand body
uniform vec4 sand_color_2 : source_color = vec4(0.78, 0.68, 0.46, 1.0);   // Sand shadows
uniform vec4 sand_color_3 : source_color = vec4(0.94, 0.88, 0.73, 1.0);   // Sand highlights

// Pebble customization settings
uniform vec4 pebble_color : source_color = vec4(0.55, 0.52, 0.50, 1.0);    // Base rock grey
uniform vec4 pebble_shadow : source_color = vec4(0.35, 0.32, 0.30, 1.0);   // Pebble drop shadow
uniform float pebble_density : hint_range(0.001, 0.05) = 0.015;            // How many pebbles spawn
uniform float pebble_size : hint_range(1.0, 5.0) = 2.0;                    // Max pixel radius of pebbles

uniform float threshold : hint_range(0.0, 1.0) = 0.15;
uniform float noise_strength : hint_range(0.0, 0.5) = 0.04;

// Random math generator
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Generates an offset vector for cellular grid population
vec2 hash2(vec2 p) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)))) * 43758.5453123);
}

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    
    // Transparent pixels are skipped
    if (current_color.a < 0.01) {
        discard;
    }
    
    // Calculate how close the current pixel is to our dirt targets
    float dist1 = distance(current_color.rgb, target_color_1.rgb);
    float dist2 = distance(current_color.rgb, target_color_2.rgb);
    float dist3 = distance(current_color.rgb, target_color_3.rgb);
    
    vec3 final_rgb = current_color.rgb;
    
    // Re-map colors depending on closest match
    if (dist1 < dist2 && dist1 < dist3 && dist1 < threshold) {
        final_rgb = sand_color_1.rgb;
    } else if (dist2 < dist1 && dist2 < dist3 && dist2 < threshold) {
        final_rgb = sand_color_2.rgb;
    } else if (dist3 < dist1 && dist3 < dist2 && dist3 < threshold) {
        final_rgb = sand_color_3.rgb;
    } else {
        // Fallback for intermediate colors: blends sand based on brightness
        float luma = dot(current_color.rgb, vec3(0.299, 0.587, 0.114));
        final_rgb = mix(sand_color_2.rgb, sand_color_3.rgb, luma);
    }
    
    // Inject pixelated granular sand noise
    float grain = hash(floor(UV * vec2(1024.0))) - 0.5;
    final_rgb += grain * noise_strength;
    
    // --- PEBBLE GENERATION ENGINE ---
    // Slices UV space into a pixel-snapped cellular grid to manage procedural generation boundaries
    vec2 pixel_uv = floor(UV * vec2(1024.0));
    vec2 cell_id = floor(pixel_uv / 16.0); 
    vec2 local_pixel = mod(pixel_uv, 16.0);
    
    // Check local cell and adjacent neighbor cells to avoid straight edges or clipping borders
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 target_cell = cell_id + vec2(float(x), float(y));
            vec2 rand_val = hash2(target_cell);
            
            // Checks if a pebble should spawn in this structural tracking cell boundary
            if (rand_val.x < pebble_density) {
                // Determine a random placement coordinate inside the target zone
                vec2 center_pixel = (target_cell * 16.0) + vec2(8.0) + (rand_val * 6.0 - vec2(3.0));
                float dist_to_pebble = distance(pixel_uv, center_pixel);
                
                // Calculates the variance of shape based on the cell's unique ID fingerprint
                float shape_warp = hash(target_cell) * 0.6 + 0.7;
                float dynamic_radius = pebble_size * shape_warp;
                
                // Draw the primary pebble structure body 
                if (dist_to_pebble <= dynamic_radius) {
                    final_rgb = pebble_color.rgb;
                    
                    // Simple pixel shading highlight based on virtual upper-left lighting orientation
                    if (pixel_uv.x - center_pixel.x < -0.2 || pixel_uv.y - center_pixel.y < -0.2) {
                        final_rgb += vec3(0.12);
                    }
                } 
                // Render a tiny ground-contact shadow directly underneath the pebble boundary
                else if (dist_to_pebble <= dynamic_radius + 1.2 && pixel_uv.y > center_pixel.y) {
                    final_rgb = mix(final_rgb, pebble_shadow.rgb, 0.65);
                }
            }
        }
    }
    
    COLOR = vec4(final_rgb, current_color.a);
}
