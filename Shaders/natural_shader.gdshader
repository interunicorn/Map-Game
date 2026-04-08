shader_type canvas_item;
uniform float x_offset;

void fragment() {
    vec2 wrapped_uv = vec2(fract(UV.x + x_offset), UV.y);
    COLOR = texture(TEXTURE, wrapped_uv);
}