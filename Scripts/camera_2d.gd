extends Camera2D

# --- Preloaded ---
@export var province_map: Sprite2D
@onready var province_image: Image = province_map.texture.get_image()
@onready var main_node: Node2D = get_parent()
@onready var control_node: Control = $"../CanvasLayer/Control"
@onready var shader_map: Sprite2D = $"../Shader Map"
@onready var shader_map_image: Image = shader_map.texture.get_image()
@onready var natural_map: Sprite2D = $"../Natural Map"

# --- Configuration ---
@export var zoom_speed : float = 10.0
@export var zoom_min : float = 0.1
@export var zoom_max : float = 2.0
@export var drag_sensitivity : float = 1.0
@export var camera_speed : float = 500.0
var total_pan_x: float = 0.0

# --- Internal Variables ---
var pan : bool = false
var target_zoom : float = 1.0

# --- Map Boundaries (Adjust these to your Sprite size) ---
var map_min_x = 0
var map_max_x = 16200
var map_min_y = 0
var map_max_y = 8100

func _ready():
	# Start at the center of the world
	position = Vector2i(map_max_x / 2, map_max_y / 2)
	target_zoom = zoom.x
	province_image.convert(Image.FORMAT_RGBA8)
	

func _process(delta: float) -> void:
	input(delta)

	var next_zoom = lerp(zoom.x, target_zoom, zoom_speed * delta)
	zoom = Vector2(next_zoom, next_zoom)
	
	# Keep the camera inside vertical bounds (North/South pole)
	position.y = clamp(position.y, map_min_y, map_max_y)
	
	# Update Shader Parameters
	var current_offset = fposmod(position.x / map_max_x, 1.0)
	shader_map.material.set_shader_parameter("x_offset", current_offset)
	natural_map.material.set_shader_parameter("x_offset", current_offset)
	shader_map.material.set_shader_parameter("zoom", zoom.x)

	# CRITICAL: Keep the maps following the camera exactly
	# This ensures the 'local_mouse_position' stays relative to the map correctly
	shader_map.global_position.x = position.x
	natural_map.global_position.x = position.x
	province_map.global_position.x = position.x # The invisible logic map

func input(delta):
	var directions = Input.get_vector("Left", "Right", "Up", "Down")
	
	position += directions * camera_speed * delta / zoom
	position.x = fposmod(position.x, map_max_x)
		
	total_pan_x = position.x / map_max_x
	shader_map.material.set_shader_parameter("x_offset", total_pan_x)
	natural_map.material.set_shader_parameter("x_offset", total_pan_x)
	
	if Input.is_action_just_pressed("Speed Up"):
		$"../CanvasLayer/Control".time_slider.value += 1.0
	
	if Input.is_action_just_pressed("Speed Down"):
		$"../CanvasLayer/Control".time_slider.value -= 1.0

func _unhandled_input(event: InputEvent) -> void:
	var local_pos = province_map.get_local_mouse_position()
	var local_pos_shader = shader_map.get_local_mouse_position()
	
	# --- Mouse Button Logic ---
	if event is InputEventMouseButton:
		# Zooming
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_zoom = clamp(target_zoom - 0.1, zoom_min, zoom_max)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_zoom = clamp(target_zoom + 0.1, zoom_min, zoom_max)
		
		# Panning Toggle (Holding Right Click)
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			pan = event.pressed
			if pan:
				# Optional: Change cursor to a 'grabbing' hand
				Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			else:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if province_map.centered:
					local_pos += province_map.texture.get_size() / 2
				
				var wrapped_x = fposmod(local_pos.x + (total_pan_x * 4050), 4050)
				
				var pixel_pos = Vector2i(wrapped_x, local_pos.y)
			
				var clicked_color = province_image.get_pixelv(pixel_pos)
				var hex = clicked_color.to_html(false).to_lower()
			
				if game_data.province_data.has(hex):
					var data = game_data.province_data[hex]
					print("---Province Data---", "\n" ,"hex read: ", hex, "\n", "Province: ", data.province_name, "\n", "Country: ", data.admin)
					
					control_node.selected_province(data.province_name, data.admin, data.wikipedia, data.id, clicked_color)
				
					if shader_map.centered:
						local_pos_shader += shader_map.texture.get_size() / 2
						
					var wrapped_x_shader = fposmod(local_pos_shader.x + (total_pan_x * 4050), 4050)
					
					var pixel_pos_shader = Vector2i(wrapped_x_shader, local_pos_shader.y)
				
					var shader_mouse_pos = shader_map_image.get_pixelv(pixel_pos_shader)

					var r = int(shader_mouse_pos.r * 255.0)
					var g = int(shader_mouse_pos.g * 255.0)
					var clicked_id = r + (g * 256)
				
					game_data.select_province(clicked_id, data.admin)
					
	# --- Dragging Logic ---
	if event is InputEventMouseMotion and pan:
		position.x -= event.relative.x * drag_sensitivity / zoom.x
		position.y -= event.relative.y * drag_sensitivity / zoom.y
		
		position.x = fposmod(position.x, map_max_x)
		
		total_pan_x = position.x / map_max_x
		shader_map.material.set_shader_parameter("x_offset", total_pan_x)
		natural_map.material.set_shader_parameter("x_offset", total_pan_x)
