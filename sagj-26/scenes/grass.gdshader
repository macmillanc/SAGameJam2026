shader_type canvas_item;

uniform vec4 spring_color : source_color = vec4(0.55, 0.80, 0.35, 1.0);
uniform vec4 summer_color : source_color = vec4(0.30, 0.65, 0.20, 1.0);
uniform vec4 autumn_color : source_color = vec4(0.80, 0.45, 0.15, 1.0);
uniform vec4 winter_color : source_color = vec4(0.85, 0.90, 0.90, 1.0);

uniform int season = 0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    vec4 season_color;

    if (season == 0) {
        season_color = spring_color;
    } else if (season == 1) {
        season_color = summer_color;
    } else if (season == 2) {
        season_color = autumn_color;
    } else {
        season_color = winter_color;
    }

    // Keep the original texture's brightness/detail
    float brightness = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

    COLOR = vec4(season_color.rgb * brightness, tex.a);
}