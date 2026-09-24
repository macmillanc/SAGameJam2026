shader_type canvas_item;
render_mode blend_mix;

// Acid Styling (Slightly darker/deeper toxic tones for the bottom layer)
uniform vec4 liquid_base : source_color = vec4(0.06, 0.18, 0.05, 1.0);    
uniform vec4 liquid_ripple : source_color = vec4(0.15, 0.5, 0.1, 1.0);   
uniform vec4 liquid_highlight : source_color = vec4(0.5, 0.8, 0.15, 1.0); 

// Behavior controls
uniform float flow_speed : hint_range(0.0, 2.0) = 0.4;
uniform float texture_scale : hint_range(0.1, 10.0) = 2.5;
uniform float micro_grain : hint_range(0.0, 0.2) = 0.05;

// Bridge to transfer world coordinates from the vertex to the fragment processor
varying vec2 world_pos;

// Procedural 2D Noise Generator (Rotation Independent)
vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453123) * 2.0 - 1.0;
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

// Layered Fractal Noise for organic, non-uniform liquid flow
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.5)));
    for (int i = 0; i < 3; i++) {
        v += a * noise(p);
        p = rot * p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void vertex() {
    // Calculate stable world position without vertex displacement (no waves for deep layer)
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    // 1. Get original sprite/texture mask
    vec4 orig_tex = texture(TEXTURE, UV);
    if (orig_tex.a < 0.01) {
        discard;
    }

    // 2. USE CALCULATED WORLD COORDINATES
    vec2 liquid_uv = world_pos * 0.01 * texture_scale;

    // 3. Dual-layered scrolling vectors
    float time = TIME * flow_speed;
    vec2 flow_dir1 = liquid_uv + vec2(time * 0.2, time * 0.1);
    vec2 flow_dir2 = liquid_uv + vec2(time * -0.1, time * 0.25);

    // Sample complex noise spaces
    float n1 = fbm(flow_dir1 + fbm(flow_dir2 * 1.5));
    float n2 = fbm(flow_dir2 - fbm(flow_dir1 * 1.2));
    float combined_noise = (n1 + n2) * 0.5 + 0.5; 

    // 4. Smooth blending across color bounds
    vec3 mixed_color = liquid_base.rgb;
    
    float ripple_mask = smoothstep(0.35, 0.65, combined_noise);
    float highlight_mask = smoothstep(0.60, 0.85, combined_noise);
    
    mixed_color = mix(mixed_color, liquid_ripple.rgb, ripple_mask);
    mixed_color = mix(mixed_color, liquid_highlight.rgb, highlight_mask);

    // 5. Apply subtle micro-grain
    float grain = fract(sin(dot(floor(UV * vec2(64.0)), vec2(12.9898, 78.233))) * 43758.5453123) - 0.5;
    mixed_color += grain * micro_grain;

    // 6. Blend smoothly with texture highlights
    float orig_luma = dot(orig_tex.rgb, vec3(0.299, 0.587, 0.114));
    mixed_color = mix(mixed_color, mixed_color * (orig_luma * 1.2), 0.3);

    COLOR = vec4(mixed_color, orig_tex.a);
}