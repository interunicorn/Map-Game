shader_type canvas_item;

uniform sampler2D lut_texture : filter_nearest;
uniform float total_provinces = 4552.0;
uniform float map_opacity : hint_range(0.0, 1.0) = 1.0;
uniform float zoom = 1.0;
uniform float min_opacity : hint_range(0.0, 1.0) = 0.2;
uniform float max_opacity : hint_range(0.0, 1.0) = 0.8;
uniform float clicked_id : hint_range(-1.0, 5000) = -1.0;
uniform float clicked_country;

uniform float x_offset = 0.0;

void fragment() {
	vec2 wrapped_uv = UV;
	
	wrapped_uv.x = fract(UV.x + x_offset);
	
	vec4 map_pixel = texture(TEXTURE, wrapped_uv);
    
    // If the pixel is fully transparent (ocean), don't color it
    if (map_pixel.a < 0.1) {
        discard;
    }

    // Using floor + 0.5 is safer than round for raw data textures
    float r = floor(map_pixel.r * 255.0 + 0.5);
    float g = floor(map_pixel.g * 255.0 + 0.5);
    float raw_id = r + (g * 256.0);
    
    // Hit the center of the pixel in the 1D LUT
    // Instead of just / total_provinces
	float lut_x = (raw_id + 0.5) / total_provinces;
    
    vec4 country_color = texture(lut_texture, vec2(lut_x, 0.5));
	
	float zoom_factor = clamp(0.90 / zoom, min_opacity, max_opacity);
	float final_opacity = map_pixel.a * map_opacity * zoom_factor;
	
    // If this pixel belongs to the selected province, make it brighter
	if (abs(raw_id - clicked_id) < 0.1) {
    	float pulse = 0.2 + (0.1 * sin(TIME * 4.0));
		country_color.rgb += pulse;
	}
    // Apply the color but keep the original texture's alpha (for anti-aliasing)
    COLOR = vec4(country_color.rgb, final_opacity);

}