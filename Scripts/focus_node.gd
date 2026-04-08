extends GraphNode
class_name focus_node

@export var _title: String
@export var description: String
@export var time_to_complete: int = 70
@export var icon: Texture2D
@export var prerequisites: Array[focus_node] = []

@export var pp_reward: float = 0
@export var stability: float = 0
@export var war_support: float = 0

func _ready() -> void:
	title = _title
