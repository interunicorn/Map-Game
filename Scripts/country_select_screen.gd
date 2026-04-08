extends Control

@export var country_group : ButtonGroup
@export var country_button_scene: PackedScene
@export var play_button_scene: PackedScene
@export var backgrounds: Array[Texture2D] = []
@onready var button_container = $PanelContainer/GridContainer
@onready var main_scene = load("res://Scenes/main.tscn")

func _ready() -> void:
	create_buttons()
	set_background()
	
func create_buttons():
	for country in game_data.countries.values():
		if country.select_screen:
			var new_button = country_button_scene.instantiate()
			
			if country.flag_icon:
				new_button.icon = country.flag_icon
				
			new_button.pressed.connect(_on_country_selected.bind(country.country_name_for_csv))
			new_button.button_group = country_group
			
			button_container.add_child(new_button)
			
	var play_button = play_button_scene.instantiate()
	play_button.pressed.connect(_on_button_play_button_down)
	
	button_container.add_child(play_button)
	
func set_background():
	var choice = backgrounds[randi() % backgrounds.size()]
	$TextureRect.texture = choice
	
func _on_country_selected(country_name: String):
	for country in game_data.countries.values():
		if country_name == country.country_name_for_csv:
			country.is_player = true
			
			game_data.current_country_res = game_data.countries[country_name]

func _on_button_play_button_down() -> void:
	for country in game_data.countries.values():
		if country.is_player:
			game_data.day_timer.start()
			get_tree().change_scene_to_packed(main_scene)
