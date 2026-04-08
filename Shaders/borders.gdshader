shader_type canvas_item;

// You must assign your province map PNG to this slot in the Inspector
uniform sampler2D province_map : filter_nearest, source_color; 
uniform float line_width : hint_range(0.0, 5.0) = 1.0;
uniform vec4 line_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // We sample from our specific uniform instead of the generic 'TEXTURE'
    vec2 size = TEXTURE_PIXEL_SIZE * line_width;
    vec4 center = texture(province_map, UV);
    
    vec4 n1 = texture(province_map, UV + vec2(size.x, 0.0));
    vec4 n2 = texture(province_map, UV + vec2(-size.x, 0.0));
    vec4 n3 = texture(province_map, UV + vec2(0.0, size.y));
    vec4 n4 = texture(province_map, UV + vec2(0.0, -size.y));
    
    float diff = distance(center, n1) + distance(center, n2) + distance(center, n3) + distance(center, n4);
    
    // If the difference is greater than zero, it's an edge
    if (diff > 0.01) {
        COLOR = line_color;
    } else {
        COLOR = vec4(0.0); // Transparent
    }
}