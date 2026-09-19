shader_type spatial;

uniform vec3 hole_world_position;
uniform float hole_radius : hint_range(0.0, 5.0) = 1.0;
uniform vec4 albedo_color : source_color = vec4(1.0);

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float distance_to_hole = distance(world_position, hole_world_position);
    if (distance_to_hole < hole_radius) {
        discard;
    }
    ALBEDO = albedo_color.rgb;
}
