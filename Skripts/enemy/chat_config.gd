extends Resource
class_name ChatConfig

@export var model: String = "internvl2.5-8b"
@export var api_key: String
@export var api_endpoint: String = "https://api.ai.rh-koeln.de/v1/chat/completions"
@export var initial_messages: Array[ChatMessage] = []
@export var friendly_name: String = "ChatGPT"