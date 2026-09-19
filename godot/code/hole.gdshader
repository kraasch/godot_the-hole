shader_type spatial;

uniform float transparency : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    ALBEDO = vec3(1.0, 0.0, 0.0);
    ALPHA = transparency;
}
