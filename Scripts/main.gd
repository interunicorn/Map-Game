extends Node2D

func _ready() -> void:
	game_data.load_provinces("res://Assets/UI/1933 Province Data.csv")
	game_data.update_map_visuals($"Shader Map".material)
	game_data.shader_map = $"Shader Map"
