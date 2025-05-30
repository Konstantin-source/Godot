extends Node2D

signal response_received(full_text: String)

@export var chat_config: ChatConfig

var headers: Array[String] = []
var messages: Array[Dictionary] = []
var is_loading: bool = false
var max_displayed: int = 1

func _ready():
	headers = [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % chat_config.api_key,
		"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.3"
	]
	for msg in chat_config.initial_messages:
		messages.append({
			"role": msg.role,
			"content": msg.content,
			"should_request": msg.should_request
		})
	$HTTPRequest.request_completed.connect(_on_request_completed)

func add_message(role: String, content: String, should_request: bool = true) -> void:
	messages.append({
		"role": role,
		"content": content,
		"should_request": should_request
	})
	emit_signal("response_received", _format_messages())
	if should_request:
		_send_to_api()

func _send_to_api() -> void:
	if is_loading:
		return
	is_loading = true

	var api_messages: Array = []
	for m in messages:
		api_messages.append({
			"role": m["role"],
			"content": m["content"]
		})

	var payload: Dictionary = {
		"model": chat_config.model,
		"messages": api_messages
	}
	var body: String = JSON.stringify(payload)
	$HTTPRequest.request(
		chat_config.api_endpoint, headers, HTTPClient.METHOD_POST, body
	)

func _on_request_completed(_result, _code, _hdrs, body) -> void:
	is_loading = false
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	add_message("assistant", json["choices"][0]["message"]["content"], false)
	emit_signal("response_received", _format_messages())

func _format_messages() -> String:
	var lines: Array[String] = []
	for m in messages:
		lines.append("%s: %s" % [m["role"].capitalize() if m["role"] != "assistant" else chat_config.friendly_name, m["content"]])

	lines = lines.filter(func(line: String) -> bool:
		return not line.begins_with("System:") and not line.begins_with("system:")
	)

	if lines.size() > max_displayed:
		lines = lines.slice(lines.size() - max_displayed, lines.size())

	var txt: String = ""
	for i in range(lines.size()):
		txt += lines[i]
		if i < lines.size() - 1:
			txt += "\n"
	return txt
