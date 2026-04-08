extends GraphElement

@onready var popup: Popup = $"../Popup"
@onready var popup_label: Label = $"../Popup/Label"

func _ready() -> void:
	$GraphEdit.connect_node("Hello", 0, "What", 0)

func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	$GraphEdit.connect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_node_selected(node: Node) -> void:
	popup_label.text = node.description
	popup.visible = true
	
func _on_button_button_down() -> void:
	popup.visible = false
