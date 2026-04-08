extends Control

@onready var flag_icon = $PanelContainer2/VBoxContainer/HBoxContainer/Flag
@onready var pp_label = $"PanelContainer2/VBoxContainer/HBoxContainer/Political Power"
@onready var stability_label = $PanelContainer2/VBoxContainer/HBoxContainer/Stability
@onready var war_support_label = $"PanelContainer2/VBoxContainer/HBoxContainer/War Support"

@onready var hour_label = $PanelContainer3/VBoxContainer/HBoxContainer/Hour
@onready var day_label = $PanelContainer3/VBoxContainer/HBoxContainer/Day
@onready var month_label = $PanelContainer3/VBoxContainer/HBoxContainer/Month
@onready var year_label = $PanelContainer3/VBoxContainer/HBoxContainer/Year
@onready var time_slider = $PanelContainer3/VBoxContainer/HBoxContainer2/HSlider

func _ready() -> void:
	if not game_data.day_tick.is_connected(update_ui) or not game_data.hour_tick.is_connected(update_ui_time):
		game_data.day_tick.connect(update_ui)
		game_data.hour_tick.connect(update_ui_time)
	
	if game_data.current_country_res:
		flag_icon.icon = game_data.current_country_res.flag_icon

func selected_province(province_name, country, wikipedia, id,clicked_color):
	var text = province_name + "\n" + country + "\n" + id + "\n"
	
	if wikipedia != "":
		text += "[url]" + wikipedia + "[/url]"
	
	$PanelContainer/VBoxContainer/RichTextLabel.text = text
	$PanelContainer/VBoxContainer/ColorRect.color = clicked_color
	
func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
	
func update_ui():
	pp_label.text = str(game_data.current_country_res.political_power)
	stability_label.text = str(game_data.current_country_res.stability * 100) + "%"
	war_support_label.text = str(game_data.current_country_res.war_support * 100) + "%"
	
func update_ui_time():
	hour_label.text = str(game_data.hour) + ":00"
	day_label.text = str(game_data.day_of_month)
	month_label.text = str(game_data.current_month_name)
	year_label.text = str(game_data.year)
	
func _on_h_slider_value_changed(value: float) -> void:
	game_data.time_scale = value
	
	if value > 0:
		if game_data.day_timer.paused:
			game_data.day_timer.paused = false
			
		game_data.day_timer.wait_time = game_data.base_speed / value
	
	else:
		game_data.day_timer.paused = true
