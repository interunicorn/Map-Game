extends Resource
class_name country_data

@export var country_name: String = ""
@export var country_name_for_csv: String = ""

@export var current_econemy_focus: String

@export var color: Color = Color.WHITE

@export var political_power: float = 0
@export var base_pp_gain: int = 2.0

@export var parties: Dictionary[String, float] = {}

@export_range(0, 1) var stability: float = 0.5
@export_range(0, 1) var war_support: float = 0.5

@export var is_major: bool = false
@export var is_player: bool = false
@export var puppet_of: String = ""

@export var select_screen: bool = false

@export var flag_icon: Texture2D
