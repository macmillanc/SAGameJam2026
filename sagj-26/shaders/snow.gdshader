shader_type canvas_item;

// Adjust these speeds to change how fast it drifts horizontally and falls vertically
uniform vec2 scroll_speed = vec2(20.0, 150.0);

void fragment() {
    // Scales the motion smoothly across the repeating texture coordinates
    vec2 scrolled_uv = UV + (TIME * scroll_speed * 0.002);
    COLOR = texture(TEXTURE, scrolled_uv);
}