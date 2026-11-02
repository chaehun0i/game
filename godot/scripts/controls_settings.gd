class_name HaeondongControlsSettings
extends RefCounted

const ACTIONS := [
	{"id": "move_left", "label": "왼쪽 이동", "defaults": [KEY_A, KEY_LEFT]},
	{"id": "move_right", "label": "오른쪽 이동", "defaults": [KEY_D, KEY_RIGHT]},
	{"id": "move_up", "label": "위쪽 이동", "defaults": [KEY_W, KEY_UP]},
	{"id": "move_down", "label": "아래쪽 이동", "defaults": [KEY_S, KEY_DOWN]},
	{"id": "interact", "label": "상호작용", "defaults": [KEY_E, KEY_ENTER]},
	{"id": "inventory", "label": "가방", "defaults": [KEY_I]},
	{"id": "player_info", "label": "내 정보", "defaults": [KEY_C]},
	{"id": "residents", "label": "주민 도감", "defaults": [KEY_N]},
	{"id": "calendar", "label": "달력", "defaults": [KEY_T]},
	{"id": "pause", "label": "일시정지", "defaults": [KEY_ESCAPE]},
	{"id": "help", "label": "도움말", "defaults": [KEY_F1]},
]

var bindings: Dictionary = {}


func initialize_defaults() -> void:
	bindings.clear()
	for action_data in ACTIONS:
		bindings[str(action_data["id"])] = action_data["defaults"].duplicate()
	_apply_bindings()


func restore_defaults() -> void:
	initialize_defaults()


func load_bindings(saved_bindings: Variant) -> void:
	initialize_defaults()
	if not saved_bindings is Dictionary:
		return

	var accepted_keys: Array[int] = []
	for action_data in ACTIONS:
		var action_id := str(action_data["id"])
		var stored: Variant = saved_bindings.get(action_id, null)
		if not stored is Array or stored.is_empty():
			continue
		var keycode := int(stored[0])
		if keycode <= 0 or accepted_keys.has(keycode):
			continue
		bindings[action_id] = [keycode]
		accepted_keys.append(keycode)
	_apply_bindings()


func rebind(action_id: String, keycode: int) -> String:
	if not bindings.has(action_id):
		return "바꿀 수 없는 조작입니다."
	if keycode <= 0:
		return "키보드 키를 선택해 주세요."
	var conflict := action_for_key(keycode, action_id)
	if not conflict.is_empty():
		return _action_label(conflict) + " 조작에 이미 쓰고 있어요."
	bindings[action_id] = [keycode]
	_apply_bindings()
	return ""


func action_for_key(keycode: int, except_action: String = "") -> String:
	for action_data in ACTIONS:
		var action_id := str(action_data["id"])
		if action_id == except_action:
			continue
		if (bindings.get(action_id, []) as Array).has(keycode):
			return action_id
	return ""


func label_for(action_id: String) -> String:
	var keys: Array = bindings.get(action_id, [])
	var labels: PackedStringArray = []
	for keycode in keys:
		labels.append(_key_label(int(keycode)))
	return " / ".join(labels)


func serialize() -> Dictionary:
	return bindings.duplicate(true)


func _apply_bindings() -> void:
	for action_data in ACTIONS:
		var action_id := str(action_data["id"])
		if not InputMap.has_action(action_id):
			InputMap.add_action(action_id)
		InputMap.action_erase_events(action_id)
		for keycode in bindings.get(action_id, []):
			var key_event := InputEventKey.new()
			key_event.keycode = int(keycode)
			InputMap.action_add_event(action_id, key_event)


func _action_label(action_id: String) -> String:
	for action_data in ACTIONS:
		if str(action_data["id"]) == action_id:
			return str(action_data["label"])
	return "다른"


func _key_label(keycode: int) -> String:
	match keycode:
		KEY_LEFT: return "←"
		KEY_RIGHT: return "→"
		KEY_UP: return "↑"
		KEY_DOWN: return "↓"
		KEY_ESCAPE: return "Esc"
		KEY_F1: return "F1"
		_: return OS.get_keycode_string(keycode)
