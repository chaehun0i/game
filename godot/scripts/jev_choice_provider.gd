extends Node

signal decision_received(request_id: String, choice_id: String, confidence: float, valid: bool)

const API_ENDPOINT := "https://api.typesafe.ai/v1/systemone"
const DEFAULT_MODEL := "jev-latest"

var _api_key := ""
var _request: HTTPRequest
var _pending_request_id := ""


func _ready() -> void:
	if OS.get_environment("HAEONDONG_JEV_ENABLED") != "1":
		return
	_api_key = OS.get_environment("TYPESAFE_API_KEY").strip_edges()
	if _api_key.is_empty():
		push_warning("Jev is opt-in but TYPESAFE_API_KEY is not set; rule-based decisions remain active.")
		return
	_request = HTTPRequest.new()
	_request.timeout = 3.0
	add_child(_request)
	_request.request_completed.connect(_on_request_completed)


func is_available() -> bool:
	return _request != null and not _api_key.is_empty()


func request_choice(request_id: String, state: Dictionary, questions: Dictionary) -> bool:
	if not is_available() or not _pending_request_id.is_empty():
		return false
	var payload := {"model": DEFAULT_MODEL, "state": state, "questions": questions}
	var headers := ["Authorization: Bearer " + _api_key, "Content-Type: application/json"]
	_pending_request_id = request_id
	var error := _request.request(API_ENDPOINT, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		_pending_request_id = ""
		return false
	return true


func parse_choice_response(body_text: String, allowed_choices: Array[String]) -> Dictionary:
	var parsed: Variant = JSON.parse_string(body_text)
	if not parsed is Dictionary:
		return {"valid": false, "choice_id": "", "confidence": 0.0}
	var answers: Variant = parsed.get("answers", {})
	if not answers is Dictionary:
		return {"valid": false, "choice_id": "", "confidence": 0.0}
	var answer: Variant = answers.get("evening_scene", {})
	if not answer is Dictionary or str(answer.get("type", "")) != "choice":
		return {"valid": false, "choice_id": "", "confidence": 0.0}
	var choice_id := str(answer.get("choice", ""))
	var confidence := float(answer.get("confidence", 0.0))
	if not allowed_choices.has(choice_id) or not is_finite(confidence) or confidence < 0.0 or confidence > 1.0:
		return {"valid": false, "choice_id": "", "confidence": 0.0}
	return {"valid": true, "choice_id": choice_id, "confidence": confidence}


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var request_id := _pending_request_id
	_pending_request_id = ""
	if request_id.is_empty():
		return
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		decision_received.emit(request_id, "", 0.0, false)
		return
	var parsed := parse_choice_response(body.get_string_from_utf8(), ["pair_0", "pair_1", "quiet_evening"])
	decision_received.emit(request_id, str(parsed.choice_id), float(parsed.confidence), bool(parsed.valid))
