extends Node

signal day_tick
signal hour_tick

var shader_map: Sprite2D

@onready var day_timer: Timer
@onready var base_speed: float = 0.4
var time_scale: float
var hour: int = 0
var day: int = 1
var month: int = 0
var months: Dictionary = {
	"January": 31,
 	"February": 59,
 	"March": 90,
 	"April": 120,
 	"May": 151,
 	"June": 181,
 	"July": 212,
 	"August": 242,
 	"September": 273,
 	"October": 303,
 	"November": 334,
 	"December": 365
}
var day_of_month: int = 1
var current_month_name: String = "January"
var year: int = 1933

var province_data := {}
var countries_folder : String = "res://Assets/Country Data/"
@onready var current_country_res: Resource
var countries : Dictionary[String, country_data] = {
	"Germany": load("res://Assets/Country Data/germany.tres"),
 	"France": load("res://Assets/Country Data/france.tres"),
	"United Kingdom": load("res://Assets/Country Data/united_kingdom.tres"),
	"United States of America": load("res://Assets/Country Data/United States of America.tres"),
	"Canada": load("res://Assets/Country Data/canada.tres"),
	"Italy": load("res://Assets/Country Data/italy.tres"),
	"Belgium": load("res://Assets/Country Data/belgium.tres")
	}


func _ready() -> void:
	day_timer = Timer.new()
	add_child(day_timer)
	day_timer.paused = true
	day_timer.wait_time = base_speed
	day_timer.autostart = true
	day_timer.timeout.connect(time)

func load_provinces(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	
	if not file:
		print("Error, could not open CSV file")
		return
		
	var _header = file.get_csv_line()
	
	while !file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < 4: continue
		
		var id = row[0]
		var wikipedia = row[1]
		var province_name = row[2]
		var admin = row[3]
		var DMZ = row[4] if row.size() > 4 else "0"
		var raw_hex = row[5]
		
		
		var hex_id = raw_hex.strip_edges().to_lower()
		province_data[hex_id] = {
			"id": id,
			"wikipedia": wikipedia,
			"province_name": province_name,
			"admin": admin,
			"DMZ": DMZ == "1"
		}
		#
func update_map_visuals(province_map_material):
	if province_data.is_empty():
		print("ERROR: province_data is empty! Map cannot be drawn.")
		return

	# Using 4552 (0 to 4551)
	var lut_image = Image.create(4551, 1, false, Image.FORMAT_RGB8)
	var match_count = 0

	for hex in province_data:
		var data = province_data[hex]
		var _country = str(data["admin"]).strip_edges()
		var id = int(data["id"]) 
		
		for country_res in countries.values():
			if country_res.country_name_for_csv == data["admin"]:
				var color_to_paint = country_res.color
				lut_image.set_pixel(id, 0, color_to_paint)
				match_count += 1
				break
		
	var tex = ImageTexture.create_from_image(lut_image)
	province_map_material.set_shader_parameter("lut_texture", tex)
	
	print("LUT Update Complete. Found colors for ", match_count, " out of ", province_data.size(), " provinces.")
	
func select_province(clicked_id, clicked_country):
	if shader_map:
		shader_map.material.set_shader_parameter("clicked_id", clicked_id)
		shader_map.material.set_shader_parameter("clicked_country", clicked_country)
		
func time():
	hour += 1
	hour_tick.emit()
	
	if hour >= 23:
		hour = 0
		day += 1
		
		var prev_month_days: int = 0
		
		for month_key in months:
			if day <= months[month_key]:
				current_month_name = month_key
				break
			prev_month_days = months[month_key]
		
		day_of_month = day - prev_month_days
		
		for country in countries:
			var data = countries[country]
			data.political_power += data.base_pp_gain
			
		day_tick.emit()
			
		if day > 365:
			day = 1
			year += 1
