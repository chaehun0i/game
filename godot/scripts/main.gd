extends Node2D

const PLAYER_SCRIPT := preload("res://scripts/player.gd")
const RESIDENT_SCRIPT := preload("res://scripts/resident.gd")
const SAVE_PATH := "user://haeondong_world.cfg"
const DAY_MINUTES := 1440

const PLACES := {
	"골목": Vector2(480, 276), "집": Vector2(150, 145), "서점": Vector2(355, 145),
	"우체국": Vector2(570, 145), "학교": Vector2(805, 145), "시장": Vector2(150, 374),
	"카페": Vector2(355, 374), "꽃집": Vector2(570, 374), "도서관": Vector2(805, 374),
	"공방": Vector2(450, 276), "공원": Vector2(666, 276)
}

const BUILDINGS := [
	{"name":"집", "color":"bb9261", "position":Vector2(150, 145)},
	{"name":"서점", "color":"718e68", "position":Vector2(355, 145)},
	{"name":"우체국", "color":"7996ad", "position":Vector2(570, 145)},
	{"name":"학교", "color":"bf795d", "position":Vector2(805, 145)},
	{"name":"시장", "color":"8ba45f", "position":Vector2(150, 374)},
	{"name":"카페", "color":"b87559", "position":Vector2(355, 374)},
	{"name":"꽃집", "color":"b77b91", "position":Vector2(570, 374)},
	{"name":"도서관", "color":"8580a4", "position":Vector2(805, 374)},
	{"name":"공방", "color":"937655", "position":Vector2(450, 276)}
]

const RESIDENTS := [
	{"id":"yun", "name":"윤", "role":"동네 책방 주인", "home":"서점", "workplace":"서점", "color":"d6e3d1", "schedule":["서점","서점","골목","도서관","서점","공원","서점"], "preferences":["조용한 아침 산책","오래된 소설"], "goal":"책방에 작은 책 교환 서가를 만들고 싶다"},
	{"id":"minjae", "name":"민재", "role":"카페 바리스타", "home":"카페", "workplace":"카페", "color":"edddc9", "schedule":["카페","카페","공원","카페","도서관","카페","골목"], "preferences":["인디 음악","새로운 원두"], "goal":"작은 음악 모임을 열고 싶다"},
	{"id":"yerin", "name":"예린", "role":"도서관 사서", "home":"도서관", "workplace":"도서관", "color":"e5dced", "schedule":["도서관","도서관","카페","공원","도서관","골목","도서관"], "preferences":["독립서점 구경","식물 기르기"], "goal":"읽고 싶은 책 목록을 완성하고 싶다"},
	{"id":"sua", "name":"수아", "role":"꽃집 주인", "home":"꽃집", "workplace":"꽃집", "color":"f0d9d8", "schedule":["꽃집","꽃집","공원","꽃집","시장","꽃집","골목"], "preferences":["들꽃 산책","꽃꽂이"], "goal":"동네 꽃으로 작은 전시를 열고 싶다"},
	{"id":"dohyeon", "name":"도현", "role":"우편 배달원", "home":"우체국", "workplace":"우체국", "color":"d6e4ec", "schedule":["우체국","골목","우체국","시장","우체국","골목","공원"], "preferences":["자전거 정비","따뜻한 차"], "goal":"오래된 편지를 주인에게 전하고 싶다"},
	{"id":"gaeun", "name":"가은", "role":"공방 목공예가", "home":"공방", "workplace":"공방", "color":"e9dfc9", "schedule":["공방","공방","골목","공원","공방","시장","공방"], "preferences":["나무 냄새","고장 난 물건 수리"], "goal":"이웃이 함께 쓰는 수리 작업대를 만들고 싶다"},
	{"id":"junho", "name":"준호", "role":"시장 채소 가게 직원", "home":"시장", "workplace":"시장", "color":"dfe8cf", "schedule":["시장","시장","시장","골목","시장","공원","시장"], "preferences":["새벽 공기","간단한 요리"], "goal":"남는 채소를 이웃과 나누고 싶다"},
	{"id":"daeun", "name":"다은", "role":"카페 음악 강사", "home":"카페", "workplace":"카페", "color":"e7d8ec", "schedule":["카페","학교","카페","공원","학교","카페","골목"], "preferences":["통기타","낯선 노래 듣기"], "goal":"초보자도 참여할 수 있는 연주 모임을 만들고 싶다"},
	{"id":"taeo", "name":"태오", "role":"학교 교사", "home":"학교", "workplace":"학교", "color":"d9e2ee", "schedule":["학교","학교","도서관","학교","공원","학교","골목"], "preferences":["별자리 관찰","어려운 질문"], "goal":"동네에 열린 저녁 수업을 마련하고 싶다"},
	{"id":"somin", "name":"소민", "role":"재택 번역가", "home":"집", "workplace":"집", "color":"eadfd3", "schedule":["집","집","도서관","집","카페","집","공원"], "preferences":["창가의 화분","비 오는 날"], "goal":"오래 미뤄 둔 번역 원고를 끝내고 싶다"}
]

var player: HaeondongPlayer
var residents: Array[HaeondongResident] = []
var relationships := {}
var events: Array[String] = []
var day := 1
var game_minute := 8 * 60
var money := 18
var energy := 82.0
var hunger := 28.0
var time_accumulator := 0.0
var last_hour := -1
var dialogue_resident: HaeondongResident
var pending_resident_id := ""
var clock_label: Label
var resource_label: Label
var interaction_label: Label
var story_label: Label
var dialogue_panel: PanelContainer
var dialogue_text: Label
var action_buttons: Array[Button] = []
var last_paid_day := 0


func _ready() -> void:
	queue_redraw()
	var saved_world := _load_world()
	_create_residents(saved_world)
	_create_player(saved_world)
	_create_hud()
	_update_daily_schedule()
	_update_hud()
	_add_event("해온동에 이사 왔어요. 어디든 천천히 둘러보세요.")


func _process(delta: float) -> void:
	if not dialogue_panel.visible:
		time_accumulator += delta
		while time_accumulator >= 1.0:
			time_accumulator -= 1.0
			_advance_time(10)
		_update_interaction_hint()
	if not pending_resident_id.is_empty():
		var approaching := _resident_by_id(pending_resident_id)
		if approaching == null or player.global_position.distance_to(approaching.global_position) <= 54.0:
			pending_resident_id = ""
			if approaching != null:
				_open_dialogue(approaching)
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if dialogue_panel != null and dialogue_panel.visible:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			_close_dialogue()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_ENTER:
			_interact_nearby()
			get_viewport().set_input_as_handled()
		elif event.keycode >= KEY_1 and event.keycode <= KEY_6:
			_perform_action(["work", "talk", "rest", "read", "eat", "local"][event.keycode - KEY_1])
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_world_tap(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_world_tap(event.position)


func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("bfd5ad"))
	# Grass lots with a quiet paper-like pixel texture.
	for lot in [Rect2(24, 26, 340, 188), Rect2(596, 26, 340, 188), Rect2(24, 325, 336, 106), Rect2(596, 325, 340, 106)]:
		draw_rect(lot, Color("b6cda4"))
	# Streets and sidewalks make the neighborhood legible at a glance.
	draw_rect(Rect2(0, 230, 960, 96), Color("e7d8b8"))
	draw_rect(Rect2(0, 240, 960, 76), Color("e0d0ad"))
	draw_rect(Rect2(425, 0, 98, 540), Color("e7d8b8"))
	draw_rect(Rect2(435, 0, 78, 540), Color("e0d0ad"))
	draw_rect(Rect2(0, 273, 960, 2), Color("c6b794"))
	draw_rect(Rect2(473, 0, 2, 540), Color("c6b794"))
	# Crosswalks, garden beds, trees, and a few benches add visual rhythm.
	for stripe in range(5):
		draw_rect(Rect2(442 + stripe * 13, 246, 6, 24), Color("f2e8d0"))
	for tree in [Vector2(75, 86), Vector2(294, 76), Vector2(655, 73), Vector2(893, 86), Vector2(82, 382), Vector2(316, 395), Vector2(865, 390), Vector2(706, 110)]:
		_draw_tree(tree)
	# Park and workshop sit beside the small central square.
	draw_rect(Rect2(586, 222, 164, 108), Color("a9c69a"))
	draw_rect(Rect2(594, 230, 148, 92), Color("bfd4a8"))
	_draw_tree(Vector2(620, 251))
	_draw_tree(Vector2(722, 252))
	draw_rect(Rect2(660, 288, 30, 5), Color("957556"))
	draw_rect(Rect2(670, 282, 3, 10), Color("957556"))
	for building in BUILDINGS:
		_draw_building(building)
	draw_string(ThemeDB.fallback_font, Vector2(640, 316), "공원", HORIZONTAL_ALIGNMENT_CENTER, 64, 12, Color("3f6747"))
	draw_string(ThemeDB.fallback_font, Vector2(458, 304), "골목", HORIZONTAL_ALIGNMENT_CENTER, 50, 11, Color("68745f"))
	# Small paving marks help communicate where the paths lead.
	for stone in [Vector2(386, 250), Vector2(386, 298), Vector2(548, 250), Vector2(548, 298), Vector2(390, 337), Vector2(545, 337)]:
		draw_rect(Rect2(stone.x, stone.y, 8, 3), Color("c8b991"))


func _draw_tree(at: Vector2) -> void:
	draw_rect(Rect2(at.x - 2, at.y + 8, 5, 12), Color("86684b"))
	draw_rect(Rect2(at.x - 11, at.y - 4, 22, 16), Color("71936a"))
	draw_rect(Rect2(at.x - 8, at.y - 9, 16, 17), Color("88a978"))
	draw_rect(Rect2(at.x - 4, at.y - 8, 5, 4), Color("a5bf87"))


func _draw_building(building: Dictionary) -> void:
	var center: Vector2 = building.position
	var wall := Color(str(building.color))
	draw_rect(Rect2(center.x - 48, center.y - 68, 100, 65), Color(0.24, 0.31, 0.25, 0.2))
	draw_rect(Rect2(center.x - 48, center.y - 70, 96, 62), Color("f4ebd7"))
	draw_rect(Rect2(center.x - 53, center.y - 77, 106, 16), wall.darkened(0.16))
	draw_rect(Rect2(center.x - 49, center.y - 81, 98, 13), wall)
	draw_rect(Rect2(center.x - 34, center.y - 58, 15, 13), Color("c4d8d0"))
	draw_rect(Rect2(center.x + 18, center.y - 58, 15, 13), Color("c4d8d0"))
	draw_rect(Rect2(center.x - 4, center.y - 36, 13, 28), wall.darkened(0.25))
	draw_rect(Rect2(center.x - 1, center.y - 33, 3, 3), Color("f3d38f"))
	draw_string(ThemeDB.fallback_font, Vector2(center.x - 48, center.y + 13), building.name, HORIZONTAL_ALIGNMENT_CENTER, 96, 12, Color("455340"))


func _create_residents(saved_world: Dictionary) -> void:
	var resident_states: Dictionary = saved_world.get("resident_states", {})
	for data in RESIDENTS.slice(0, 3):
		var resident := RESIDENT_SCRIPT.new() as HaeondongResident
		resident.configure(data, _resident_slot(str(data.home), residents.size()))
		var state: Dictionary = resident_states.get(resident.resident_id, {})
		resident.player_affinity = int(relationships.get(resident.resident_id, 0))
		resident.goal_progress = int(state.get("goal_progress", 0))
		resident.energy = float(state.get("energy", 82.0))
		resident.hunger = float(state.get("hunger", 30.0))
		resident.social_need = float(state.get("social_need", 42.0))
		resident.money = int(state.get("money", 50))
		resident.memories.assign(state.get("memories", []))
		add_child(resident)
		residents.append(resident)


func _create_player(saved_world: Dictionary) -> void:
	player = PLAYER_SCRIPT.new() as HaeondongPlayer
	player.name = "Player"
	player.global_position = PLACES["골목"] + Vector2(4, 18)
	player.z_index = 20
	add_child(player)
	var saved_position: Vector2 = saved_world.get("player_position", player.global_position)
	player.global_position = saved_position


func _resident_slot(place: String, index: int) -> Vector2:
	var center: Vector2 = PLACES.get(place, PLACES["골목"])
	var offsets := [Vector2(-14, 16), Vector2(14, 20), Vector2(0, 34), Vector2(-24, 30)]
	return center + offsets[index % offsets.size()]


func _location_of(point: Vector2) -> String:
	var closest := "골목"
	var distance := INF
	for place in PLACES:
		var next_distance: float = point.distance_squared_to(PLACES[place])
		if next_distance < distance:
			distance = next_distance
			closest = place
	return closest if distance < 66.0 * 66.0 else "골목"


func _create_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	var status_box := _make_panel(root, Vector2(18, 16), Vector2(330, 100))
	var title := _make_label("해온동", 22, Color("314a39"))
	status_box.add_child(title)
	clock_label = _make_label("첫째 날 · 오전 8:00 · 봄", 14, Color("63705c"))
	status_box.add_child(clock_label)
	resource_label = _make_label("기운 82   허기 28%   돈 18원", 13, Color("596c52"))
	status_box.add_child(resource_label)

	var story_box := _make_panel(root, Vector2(700, 16), Vector2(242, 108))
	story_label = _make_label("이웃들이 각자의 하루를 시작합니다.", 13, Color("465543"))
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.custom_minimum_size = Vector2(210, 54)
	story_box.add_child(_make_label("오늘의 흔적", 15, Color("314a39")))
	story_box.add_child(story_label)

	var hint_panel := _make_panel(root, Vector2(318, 16), Vector2(340, 54))
	interaction_label = _make_label("WASD로 걷기 · 이웃 가까이서 E로 대화", 12, Color("52634e"))
	hint_panel.add_child(interaction_label)

	var action_box := _make_panel(root, Vector2(18, 452), Vector2(924, 72))
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	action_box.add_child(action_row)
	_add_action_button(action_row, "카페 일", "1", "work")
	_add_action_button(action_row, "이웃과 대화", "2", "talk")
	_add_action_button(action_row, "집에서 쉬기", "3", "rest")
	_add_action_button(action_row, "책 읽기", "4", "read")
	_add_action_button(action_row, "식사하기", "5", "eat")
	_add_action_button(action_row, "장소 활동", "6", "local")

	dialogue_panel = _make_panel(root, Vector2(242, 142), Vector2(476, 270)).get_parent() as PanelContainer
	dialogue_panel.visible = false
	dialogue_panel.z_index = 50
	var dialogue_column := VBoxContainer.new()
	dialogue_column.add_theme_constant_override("separation", 10)
	dialogue_panel.add_child(dialogue_column)
	dialogue_text = _make_label("", 16, Color("354536"))
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.custom_minimum_size = Vector2(430, 82)
	dialogue_column.add_child(dialogue_text)
	_add_dialogue_button(dialogue_column, "안부를 묻는다", "ask")
	_add_dialogue_button(dialogue_column, "좋아하는 것을 묻는다", "hobby")
	_add_dialogue_button(dialogue_column, "내일 만나자고 한다", "invite")
	_add_dialogue_button(dialogue_column, "다음에 또 보기", "close")


func _make_panel(parent: Control, at: Vector2, dimensions: Vector2) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.position = at
	panel.size = dimensions
	var style := StyleBoxFlat.new()
	style.bg_color = Color("f5f0df")
	style.border_color = Color("d7cfb9")
	style.set_border_width_all(2)
	style.set_corner_radius_all(9)
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	panel.add_child(column)
	return column


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _add_action_button(parent: HBoxContainer, title: String, key: String, action: String) -> void:
	var button := Button.new()
	button.text = title + "  " + key
	button.custom_minimum_size = Vector2(138, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(func() -> void: _perform_action(action))
	parent.add_child(button)
	action_buttons.append(button)


func _add_dialogue_button(parent: VBoxContainer, title: String, action: String) -> void:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(0, 34)
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(func() -> void: _dialogue_action(action))
	parent.add_child(button)


func _perform_action(action: String) -> void:
	var place := _location_of(player.global_position)
	var elapsed := 0
	match action:
		"work":
			if place != "카페":
				_add_event("카페에 가면 두 시간 일하고 12원을 벌 수 있어요.")
				return
			elapsed = 120
			money += 12
			energy = maxf(0.0, energy - 18.0)
			_add_event("카페에서 두 시간 일해 12원을 벌었어요.")
			var barista := _resident_by_id("minjae")
			if barista != null and barista.location == "카페":
				_change_relationship(barista, 1)
				barista.memories.push_front("플레이어가 카페에서 함께 일해 주었다.")
		"talk":
			_interact_nearby()
			return
		"rest":
			if place != "집":
				_add_event("집에 도착하면 쉬며 기운을 회복할 수 있어요.")
				return
			elapsed = 180
			energy = minf(100.0, energy + 38.0)
			_add_event("집에서 쉬며 기운을 회복했어요.")
		"read":
			if place != "도서관":
				_add_event("도서관에 가면 책을 읽을 수 있어요.")
				return
			elapsed = 60
			energy = maxf(0.0, energy - 7.0)
			_add_event("도서관에서 조용히 책을 읽었어요.")
			var librarian := _resident_by_id("yerin")
			if librarian != null and librarian.location == "도서관":
				_change_relationship(librarian, 1)
				librarian.goal_progress = mini(100, librarian.goal_progress + 5)
				librarian.memories.push_front("플레이어가 도서관에서 책을 읽었다.")
		"eat":
			if place != "카페":
				_add_event("카페에서 식사할 수 있어요.")
				return
			if money < 4:
				_add_event("식사할 돈이 부족해요. 카페에서 일해 돈을 모아보세요.")
				return
			elapsed = 15
			money -= 4
			hunger = maxf(0.0, hunger - 48.0)
			energy = minf(100.0, energy + 8.0)
			_add_event("카페에서 간단히 식사했어요.")
		"local":
			match place:
				"공원":
					elapsed = 45
					energy = maxf(0.0, energy - 4.0)
					hunger = maxf(0.0, hunger - 3.0)
					_add_event("공원 길을 천천히 걸으며 나무와 골목의 소리를 들었어요.")
				"시장":
					if money < 2:
						_add_event("제철 간식을 살 돈이 부족해요.")
						return
					elapsed = 45
					money -= 2
					hunger = maxf(0.0, hunger - 16.0)
					_add_event("시장에 들러 제철 간식을 샀어요.")
				"꽃집":
					if money < 3:
						_add_event("작은 꽃다발을 살 돈이 부족해요.")
						return
					elapsed = 45
					money -= 3
					_add_event("계절 꽃을 골라 작은 꽃다발을 샀어요.")
				"공방", "서점", "도서관", "카페", "학교", "우체국":
					elapsed = 45
					energy = maxf(0.0, energy - 3.0)
					_add_event(place + "에서 잠시 시간을 보냈어요.")
				_:
					_add_event("먼저 지도를 눌러 장소를 둘러보세요.")
					return
		_:
			return

	if elapsed > 0:
		_advance_time(elapsed)
		_save_world()
	_update_hud()


func _interact_nearby() -> void:
	var closest: HaeondongResident
	var closest_distance := 54.0
	for resident in residents:
		var distance := player.global_position.distance_to(resident.global_position)
		if distance < closest_distance:
			closest = resident
			closest_distance = distance
	if closest == null:
		_add_event("가까이에 이웃이 없어요. 지도 위 이웃에게 다가가 보세요.")
		return
	_open_dialogue(closest)


func _open_dialogue(resident: HaeondongResident) -> void:
	dialogue_resident = resident
	dialogue_panel.visible = true
	player.set_physics_process(false)
	dialogue_text.text = "“안녕하세요. 저는 " + resident.resident_name + "이에요. " + resident.role + "로 일하고 있어요.”\n\n요즘 바라는 일은 " + resident.goal + "예요."
	interaction_label.text = resident.resident_name + "와 이야기하고 있어요 · Esc로 닫기"


func _dialogue_action(action: String) -> void:
	if dialogue_resident == null:
		return
	var resident := dialogue_resident
	match action:
		"ask":
			_change_relationship(resident, 1)
			resident.social_need = maxf(0.0, resident.social_need - 12.0)
			resident.memories.push_front("플레이어가 먼저 안부를 물었다.")
			dialogue_text.text = "“요즘은 " + resident.goal + " 생각을 자주 해요. 서두르지 않고 준비하고 있어요.”\n\n오늘의 대화가 " + resident.resident_name + "의 기억에 남았어요."
			_add_event(resident.resident_name + "와 안부를 나눴어요.")
		"hobby":
			dialogue_text.text = "“제가 좋아하는 건 " + ", ".join(resident.preferences) + "이에요.”"
			_change_relationship(resident, 1)
			_add_event(resident.resident_name + "가 좋아하는 것을 알려줬어요.")
		"invite":
			if resident.player_affinity >= 2:
				resident.memories.push_front("플레이어가 내일 만날 약속을 제안했다.")
				_change_relationship(resident, 1)
				dialogue_text.text = "“좋아요. 내일 오후 다섯 시에 " + _location_of(player.global_position) + "에서 만나요.”\n\n이 약속은 다음에 만남 시스템으로 이어집니다."
				_add_event(resident.resident_name + "와 내일 만나기로 했어요.")
			else:
				dialogue_text.text = "“아직은 조금 어색하네요. 다음에 더 이야기 나누고 생각해 볼게요.”"
		"close":
			_close_dialogue()
	_save_world()
	_update_hud()


func _close_dialogue() -> void:
	dialogue_panel.visible = false
	dialogue_resident = null
	player.set_physics_process(true)
	_update_hud()


func _handle_world_tap(at: Vector2) -> void:
	if dialogue_panel != null and dialogue_panel.visible:
		return
	var resident := _resident_near(at, 26.0)
	if resident != null:
		player.walk_to(resident.global_position + Vector2(16, 12))
		pending_resident_id = resident.resident_id
		return
	player.walk_to(at)


func _resident_near(at: Vector2, radius: float) -> HaeondongResident:
	var closest: HaeondongResident
	var closest_distance := radius
	for resident in residents:
		var distance := resident.global_position.distance_to(at)
		if distance < closest_distance:
			closest = resident
			closest_distance = distance
	return closest


func _resident_by_id(identifier: String) -> HaeondongResident:
	for resident in residents:
		if resident.resident_id == identifier:
			return resident
	return null


func _change_relationship(resident: HaeondongResident, amount: int) -> void:
	resident.player_affinity = mini(100, resident.player_affinity + amount)
	relationships[resident.resident_id] = resident.player_affinity
	_add_event(resident.resident_name + "와 조금 더 편하게 이야기하게 됐어요.")


func _advance_time(minutes: int) -> void:
	var old_hour := floori(float(game_minute) / 60.0)
	game_minute += minutes
	while game_minute >= DAY_MINUTES:
		game_minute -= DAY_MINUTES
		day += 1
		last_paid_day = 0
		_add_event("" + str(day) + "일째 아침이 왔어요.")
	var hour := floori(float(game_minute) / 60.0)
	if hour != old_hour:
		_update_daily_schedule()
	hunger = minf(100.0, hunger + float(minutes) * 0.012)
	energy = maxf(0.0, energy - (0.008 if hunger > 78.0 else 0.004) * float(minutes))
	var hour_now := floori(float(game_minute) / 60.0)
	for resident in residents:
		resident.hunger = minf(100.0, resident.hunger + float(minutes) * 0.12)
		resident.social_need = minf(100.0, resident.social_need + float(minutes) * 0.014)
		if hour_now >= 22 or hour_now < 7:
			resident.energy = minf(100.0, resident.energy + float(minutes) * 0.14)
		else:
			resident.energy = maxf(5.0, resident.energy - float(minutes) * 0.018)
		if hour_now in [8, 12, 19] and resident.hunger > 54.0 and resident.money >= 2:
			resident.money -= 2
			resident.hunger = maxf(10.0, resident.hunger - 32.0)
	if hour != old_hour:
		_save_world()


func _update_daily_schedule() -> void:
	var hour := floori(float(game_minute) / 60.0)
	for index in residents.size():
		var resident: HaeondongResident = residents[index]
		var place := resident.home
		if hour >= 8 and hour < 17:
			place = resident.workplace
		elif hour >= 17 and hour < 21 and not resident.schedule.is_empty():
			place = resident.schedule[(day - 1 + index) % resident.schedule.size()]
		var slot := residents.find(resident)
		resident.set_destination(place, _resident_slot(place, slot))

	if hour >= 17 and hour < 21 and last_paid_day != day:
		for resident in residents:
			resident.money += resident.daily_wage
		last_paid_day = day


func _update_interaction_hint() -> void:
	if dialogue_panel.visible:
		return
	var closest: HaeondongResident
	var closest_distance := 54.0
	for resident in residents:
		var distance := player.global_position.distance_to(resident.global_position)
		if distance < closest_distance:
			closest = resident
			closest_distance = distance
	if closest != null:
		interaction_label.text = "E: " + closest.resident_name + "와 대화"
	else:
		interaction_label.text = _location_of(player.global_position) + " · WASD로 걷기 · 이웃 가까이서 E"


func _update_hud() -> void:
	if clock_label == null:
		return
	var hour := floori(float(game_minute) / 60.0)
	var minute := game_minute % 60
	var period := "오전" if hour < 12 else "오후"
	var shown_hour := hour % 12
	if shown_hour == 0:
		shown_hour = 12
	clock_label.text = str(day) + "일째 · " + period + " " + str(shown_hour) + ":" + "%02d" % minute + " · " + _season_name()
	resource_label.text = "기운 " + str(roundi(energy)) + "   허기 " + str(roundi(hunger)) + "%   돈 " + str(money) + "원"
	if story_label != null and not events.is_empty():
		story_label.text = events[0]


func _season_name() -> String:
	return ["봄", "여름", "가을", "겨울"][floori(float(day - 1) / 7.0) % 4]


func _add_event(text: String) -> void:
	events.push_front(text)
	if events.size() > 12:
		events.resize(12)
	if story_label != null:
		story_label.text = text


func _load_world() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return {}
	day = int(config.get_value("world", "day", 1))
	game_minute = int(config.get_value("world", "minute", 8 * 60))
	money = int(config.get_value("player", "money", 18))
	energy = float(config.get_value("player", "energy", 82.0))
	hunger = float(config.get_value("player", "hunger", 28.0))
	last_paid_day = int(config.get_value("world", "last_paid_day", 0))
	var saved_relations: Variant = config.get_value("player", "relationships", {})
	if saved_relations is Dictionary:
		relationships = saved_relations.duplicate(true)
	var saved_events: Variant = config.get_value("world", "events", [])
	if saved_events is Array:
		events.assign(saved_events)
	var saved_residents: Variant = config.get_value("world", "residents", {})
	return {
		"player_position": Vector2(float(config.get_value("player", "x", 480.0)), float(config.get_value("player", "y", 294.0))),
		"resident_states": saved_residents if saved_residents is Dictionary else {}
	}


func _save_world() -> void:
	if player == null:
		return
	var config := ConfigFile.new()
	config.set_value("world", "day", day)
	config.set_value("world", "minute", game_minute)
	config.set_value("world", "last_paid_day", last_paid_day)
	config.set_value("world", "events", events)
	var resident_states := {}
	for resident in residents:
		resident_states[resident.resident_id] = {
			"goal_progress": resident.goal_progress,
			"energy": resident.energy,
			"hunger": resident.hunger,
			"social_need": resident.social_need,
			"money": resident.money,
			"memories": resident.memories.slice(0, 20)
		}
	config.set_value("world", "residents", resident_states)
	config.set_value("player", "x", player.global_position.x)
	config.set_value("player", "y", player.global_position.y)
	config.set_value("player", "money", money)
	config.set_value("player", "energy", energy)
	config.set_value("player", "hunger", hunger)
	config.set_value("player", "relationships", relationships)
	config.save(SAVE_PATH)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_world()
