extends Control

var chat_manager_path: NodePath = "/root/Game/ChatManager"
@onready var chat_manager = get_node(chat_manager_path)
@onready var messages_label = $MessagesLabel

enum StreamState { IDLE, STREAMING }
var stream_state = StreamState.IDLE

func _ready() -> void:
	chat_manager.connect("response_received", Callable(self, "_on_response_received"))

func _on_response_received(formatted: String) -> void:
	messages_label.text = formatted
