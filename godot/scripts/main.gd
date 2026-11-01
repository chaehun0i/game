extends Node2D

const PLAYER_SCRIPT := preload("res://scripts/player.gd")
const RESIDENT_SCRIPT := preload("res://scripts/resident.gd")
const NEIGHBORHOOD_BACKGROUND := preload("res://assets/haeondong_neighborhood.png")
const DEFAULT_SAVE_PATH := "user://haeondong_world.cfg"
const DAY_MINUTES := 1440
const REAL_SECONDS_PER_GAME_TICK := 3.0
const RESIDENT_PORTRAIT_INDICES := {"sua": 0, "dohyeon": 1, "gaeun": 2, "junho": 3, "daeun": 4, "taeo": 5, "somin": 6}

const PLACES := {
	"골목": Vector2(385, 230), "집": Vector2(86, 150), "서점": Vector2(287, 150),
	"우체국": Vector2(635, 153), "학교": Vector2(845, 155), "시장": Vector2(128, 386),
	"카페": Vector2(291, 386), "꽃집": Vector2(682, 386), "도서관": Vector2(845, 386),
	"공방": Vector2(488, 386), "공원": Vector2(477, 186)
}

const PLACE_LABEL_POSITIONS := {
	"집": Vector2(86, 122), "서점": Vector2(287, 122), "우체국": Vector2(635, 124), "학교": Vector2(845, 126),
	"시장": Vector2(128, 322), "카페": Vector2(291, 322), "공방": Vector2(488, 322), "꽃집": Vector2(682, 322), "도서관": Vector2(845, 322)
}

const WORK_SHIFTS := {
	"yun": Vector2i(8, 16), "minjae": Vector2i(7, 15), "yerin": Vector2i(9, 17),
	"sua": Vector2i(8, 16), "dohyeon": Vector2i(7, 15), "gaeun": Vector2i(10, 18),
	"junho": Vector2i(6, 14), "daeun": Vector2i(13, 19), "taeo": Vector2i(8, 16), "somin": Vector2i(9, 17)
}

const DAILY_SMALL_TALK := {
	"yun": ["아침 햇살이 책등에 닿으면 가게가 조금 더 포근해 보여요.", "누군가 오래 찾던 책을 발견하면 같이 기뻐하게 돼요.", "문 닫기 전엔 오늘 읽은 문장을 한 줄 적어 둬요."],
	"minjae": ["첫 잔을 내릴 때 퍼지는 향이 오늘 하루를 깨워 주네요.", "단골마다 좋아하는 커피 맛이 달라서 외우는 재미가 있어요.", "마감 뒤엔 오늘 들은 노래를 조용히 다시 들어요."],
	"yerin": ["도서관 창가 자리에 햇빛이 들어와 책 읽기 좋아요.", "반납된 책 사이에서 다음에 읽을 이야기를 찾곤 해요.", "오늘은 책장을 정리하고 나니 마음도 차분해졌어요."],
	"sua": ["아침마다 꽃병의 물을 갈면 가게에 생기가 돌아요.", "계절이 바뀌는 건 꽃잎 색부터 먼저 알려 주더라고요.", "가게 앞 꽃들이 저녁 바람에 살짝 흔들리고 있어요."],
	"dohyeon": ["오늘 편지들은 어느 집에 어떤 소식을 전할지 궁금해요.", "골목길을 돌다 보면 어제 못 본 작은 화분을 발견해요.", "배달을 마치고 나면 따뜻한 차 한 잔이 생각나요."],
	"gaeun": ["나무를 고를 때는 결을 천천히 살펴보는 편이에요.", "고장 난 물건도 조금 손보면 다시 쓸 수 있더라고요.", "작업대에 남은 톱밥을 쓸고 나면 하루가 끝난 기분이에요."],
	"junho": ["시장은 아침마다 새로운 재료 냄새로 가득해요.", "오늘 들어온 채소 중엔 간단히 볶아 먹을 게 많아요.", "남은 재료로 이웃과 나눌 간식을 만들어 볼까 해요."],
	"daeun": ["연습을 시작하기 전에 좋아하는 곡을 한 번 흥얼거려요.", "서툴러도 함께 연주하면 박자가 맞는 순간이 오더라고요.", "저녁에 카페가 한산해지면 작은 멜로디를 연습해요."],
	"taeo": ["수업 준비를 하다 보면 아이들이 할 질문이 궁금해져요.", "오늘은 누군가 별을 올려다볼 여유가 있었으면 좋겠어요.", "내일 수업에 쓸 이야기를 천천히 정리하고 있어요."],
	"somin": ["창가 화분에 물을 주고 나면 일에 다시 집중할 수 있어요.", "문장을 고치다 보면 가장 알맞은 표현이 뒤늦게 떠올라요.", "오늘은 번역을 조금 덮어 두고 조용히 쉬고 싶어요."]
}

const RESIDENTS := [
	{"id":"yun", "name":"윤", "role":"동네 책방 주인", "home":"서점", "workplace":"서점", "color":"d6e3d1", "schedule":["서점","서점","골목","도서관","서점","공원","서점"], "preferences":["조용한 아침 산책","오래된 소설"], "goal":"책방에 작은 책 교환 서가를 만들고 싶다", "private_worry":"책방 임대 계약이 끝나면 이곳을 계속 지킬 수 있을지 걱정한다"},
	{"id":"minjae", "name":"민재", "role":"카페 바리스타", "home":"집", "workplace":"카페", "color":"edddc9", "schedule":["카페","카페","공원","카페","도서관","카페","골목"], "preferences":["인디 음악","새로운 원두"], "goal":"작은 음악 모임을 열고 싶다", "private_worry":"사람들 앞에서 연주하다 실수할까 봐 망설이고 있다"},
	{"id":"yerin", "name":"예린", "role":"도서관 사서", "home":"집", "workplace":"도서관", "color":"e5dced", "schedule":["도서관","도서관","카페","공원","도서관","골목","도서관"], "preferences":["독립서점 구경","식물 기르기"], "goal":"읽고 싶은 책 목록을 완성하고 싶다", "private_worry":"해야 할 일을 자꾸 미루는 자신에게 실망할 때가 있다"},
	{"id":"sua", "name":"수아", "role":"꽃집 주인", "home":"꽃집", "workplace":"꽃집", "color":"f0d9d8", "schedule":["꽃집","꽃집","공원","꽃집","시장","꽃집","골목"], "preferences":["들꽃 산책","꽃꽂이"], "goal":"동네 꽃으로 작은 전시를 열고 싶다", "private_worry":"꽃값을 올리면 단골 이웃들이 발길을 끊을까 걱정한다"},
	{"id":"dohyeon", "name":"도현", "role":"우편 배달원", "home":"우체국", "workplace":"우체국", "color":"d6e4ec", "schedule":["우체국","골목","우체국","시장","우체국","골목","공원"], "preferences":["자전거 정비","따뜻한 차"], "goal":"오래된 편지를 주인에게 전하고 싶다", "private_worry":"주소가 적히지 않은 편지를 아직 누구에게 전해야 할지 모른다"},
	{"id":"gaeun", "name":"가은", "role":"공방 목공예가", "home":"공방", "workplace":"공방", "color":"e9dfc9", "schedule":["공방","공방","골목","공원","공방","시장","공방"], "preferences":["나무 냄새","고장 난 물건 수리"], "goal":"이웃이 함께 쓰는 수리 작업대를 만들고 싶다", "private_worry":"작업대를 열어 두면 혼자 감당할 일이 너무 많아질까 걱정한다"},
	{"id":"junho", "name":"준호", "role":"시장 채소 가게 직원", "home":"시장", "workplace":"시장", "color":"dfe8cf", "schedule":["시장","시장","시장","골목","시장","공원","시장"], "preferences":["새벽 공기","간단한 요리"], "goal":"남는 채소를 이웃과 나누고 싶다", "private_worry":"자신이 준비한 나눔을 사람들이 부담스러워할까 망설인다"},
	{"id":"daeun", "name":"다은", "role":"카페 음악 강사", "home":"집", "workplace":"카페", "color":"e7d8ec", "schedule":["카페","학교","카페","공원","학교","카페","골목"], "preferences":["통기타","낯선 노래 듣기"], "goal":"초보자도 참여할 수 있는 연주 모임을 만들고 싶다", "private_worry":"처음 오는 사람이 실수해도 편히 머물 수 있을지 고민한다"},
	{"id":"taeo", "name":"태오", "role":"학교 교사", "home":"집", "workplace":"학교", "color":"d9e2ee", "schedule":["학교","학교","도서관","학교","공원","학교","골목"], "preferences":["별자리 관찰","어려운 질문"], "goal":"동네에 열린 저녁 수업을 마련하고 싶다", "private_worry":"수업을 열어도 찾아오는 사람이 없을까 걱정한다"},
	{"id":"somin", "name":"소민", "role":"재택 번역가", "home":"집", "workplace":"집", "color":"eadfd3", "schedule":["집","집","도서관","집","카페","집","공원"], "preferences":["창가의 화분","비 오는 날"], "goal":"오래 미뤄 둔 번역 원고를 끝내고 싶다", "private_worry":"마지막 문장을 어떻게 옮길지 몰라 원고를 오래 붙잡고 있다"}
]

const STARTING_RUMORS := [
	{"listener":"yerin", "source":"yun", "subject":"minjae", "text":"민재가 카페에서 작은 음악 모임을 꿈꾸고 있대요."},
	{"listener":"daeun", "source":"minjae", "subject":"yerin", "text":"예린이 이웃과 함께 읽을 책 목록을 정리하고 있대요."},
	{"listener":"junho", "source":"sua", "subject":"somin", "text":"소민이 오래 붙잡고 있던 번역 원고를 마무리하고 싶어 한대요."},
	{"listener":"somin", "source":"taeo", "subject":"yun", "text":"윤이 책을 서로 나누는 서가를 준비하고 있대요."}
]

const RESIDENT_PERSONALITIES := {
	"yun": {"traits":["차분함", "관찰력이 좋아요"], "values":["책을 나누는 일", "약속 지키기"], "background":"이 동네 책방을 오래 지켜 오며 이웃의 취향을 하나씩 기억해 왔어요."},
	"minjae": {"traits":["사교적", "새로운 것을 좋아해요"], "values":["새로운 경험", "먼저 인사하기"], "background":"여러 곳을 다니다가 해온동 카페에 자리를 잡고 단골들의 이야기를 듣게 됐어요."},
	"yerin": {"traits":["신중함", "남을 잘 챙겨요"], "values":["차분한 배려", "꾸준히 배우기"], "background":"어릴 때부터 도서관에서 보내는 시간을 좋아했고, 이웃에게 맞는 책을 찾는 일을 즐겨요."},
	"sua": {"traits":["다정함", "세심해요"], "values":["작은 아름다움", "정직한 거래"], "background":"계절마다 달라지는 동네 풍경을 꽃으로 기록하며 가게를 꾸려 왔어요."},
	"dohyeon": {"traits":["성실함", "길을 잘 기억해요"], "values":["전할 말을 빠뜨리지 않기", "꾸준함"], "background":"해온동 골목을 오래 걸어 다녀서 누가 어느 집에 사는지 잘 알고 있어요."},
	"gaeun": {"traits":["집중력이 좋아요", "솔직해요"], "values":["오래 쓰는 물건", "손으로 익히기"], "background":"낡은 가구를 고치며 물건에 남은 이야기를 상상하는 시간이 좋아요."},
	"junho": {"traits":["활달함", "손이 빨라요"], "values":["제철 재료", "서로 돕기"], "background":"새벽 시장에서 배운 요령으로 가게 일을 돕고, 남는 재료를 아깝게 여기지 않아요."},
	"daeun": {"traits":["호기심이 많아요", "격려를 잘해요"], "values":["함께 만드는 소리", "배움의 기회"], "background":"작은 모임에서 함께 연주하는 즐거움을 나누고 싶어 카페에서 음악을 가르쳐요."},
	"taeo": {"traits":["차분함", "설명을 좋아해요"], "values":["궁금해할 시간", "공정한 기회"], "background":"동네 아이들이 무엇에 관심을 두는지 살피고 오래 생각할 수 있는 수업을 만들려 해요."},
	"somin": {"traits":["신중함", "말을 아껴요"], "values":["정확한 표현", "혼자 쉬는 시간"], "background":"다른 사람의 문장을 옮기며 자기만의 리듬과 조용한 생활을 찾아가고 있어요."}
}

var player: HaeondongPlayer
var residents: Array[HaeondongResident] = []
var relationships := {}
var events: Array[String] = []
var day := 1
var game_minute := 8 * 60
var money := 18
var energy := 82.0
var hunger := 28.0
var inventory := {"꽃다발": 0, "책": 0}
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
var dialogue_portrait: TextureRect
var dialogue_name_label: Label
var dialogue_role_label: Label
var dialogue_mood_label: Label
var action_buttons: Array[Button] = []
var last_paid_day := 0
var appointments: Array[Dictionary] = []
var last_society_day := 0
var appointment_label: Label
var journal_panel: PanelContainer
var pause_panel: PanelContainer
var help_panel: PanelContainer
var modal_scrim: ColorRect
var journal_text: Label
var help_return_to_pause := false
var gift_flower_button: Button
var gift_book_button: Button
var confide_button: Button
var journal_button: Button
var sound_button: Button
var pause_sound_button: Button
var sound_enabled := true
var chime_player: AudioStreamPlayer
var offline_minutes_to_simulate := 0
var save_path := DEFAULT_SAVE_PATH


func _ready() -> void:
	queue_redraw()
	var saved_world := _load_world()
	var is_new_world := saved_world.is_empty()
	_create_residents(saved_world)
	_initialize_connections(saved_world)
	_initialize_rumors()
	_create_player(saved_world)
	_create_hud()
	_setup_sound()
	_update_daily_schedule()
	_apply_offline_time()
	_update_hud()
	if is_new_world:
		_add_event("해온동에 이사 왔어요. 어디든 천천히 둘러보세요.")


func _process(delta: float) -> void:
	if not dialogue_panel.visible and not journal_panel.visible and not pause_panel.visible and not help_panel.visible:
		time_accumulator += delta
		while time_accumulator >= REAL_SECONDS_PER_GAME_TICK:
			time_accumulator -= REAL_SECONDS_PER_GAME_TICK
			_advance_time(10)
		_update_interaction_hint()
	if not pending_resident_id.is_empty():
		var approaching := _resident_by_id(pending_resident_id)
		if approaching == null or not approaching.visible or player.global_position.distance_to(approaching.global_position) <= 54.0:
			pending_resident_id = ""
			if approaching != null and approaching.visible:
				_open_dialogue(approaching)
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if pause_panel != null and pause_panel.visible:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			_close_pause()
			get_viewport().set_input_as_handled()
		elif event is InputEventKey and event.pressed and event.keycode == KEY_F1:
			_open_help(true)
			get_viewport().set_input_as_handled()
		return
	if help_panel != null and help_panel.visible:
		if event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_F1):
			_close_help()
			get_viewport().set_input_as_handled()
		return
	if journal_panel != null and journal_panel.visible:
		if event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_J):
			_close_journal()
			get_viewport().set_input_as_handled()
		return
	if dialogue_panel != null and dialogue_panel.visible:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			_close_dialogue()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_open_pause()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_J:
			_open_journal()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F1:
			_open_help()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E or event.keycode == KEY_ENTER:
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
	var texture_size := NEIGHBORHOOD_BACKGROUND.get_size()
	var source_height := texture_size.x * 540.0 / 960.0
	var source_y := (texture_size.y - source_height) / 2.0
	draw_texture_rect_region(NEIGHBORHOOD_BACKGROUND, Rect2(0, 0, 960, 540), Rect2(0, source_y, texture_size.x, source_height))
	for place_name in PLACE_LABEL_POSITIONS:
		_draw_building(str(place_name), PLACE_LABEL_POSITIONS[place_name])
	_draw_building("공원", Vector2(477, 158))
	_draw_building("골목", Vector2(385, 230))
	var map_hour := floori(float(game_minute) / 60.0)
	var night_alpha := 0.20 if map_hour >= 20 or map_hour < 6 else (0.08 if map_hour >= 18 else 0.0)
	if night_alpha > 0.0:
		draw_rect(Rect2(0, 0, 960, 540), Color(0.20, 0.27, 0.39, night_alpha))


func _draw_building(place_name: String, center: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var font_size := 10
	var text_width := font.get_string_size(place_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var badge := Rect2(center.x - text_width / 2.0 - 6.0, center.y - 12.0, text_width + 12.0, 18.0)
	draw_rect(badge, Color(0.95, 0.91, 0.79, 0.94))
	draw_rect(badge, Color(0.31, 0.40, 0.30, 0.9), false, 1.0)
	draw_string(font, Vector2(center.x - text_width / 2.0, center.y + 1.0), place_name, HORIZONTAL_ALIGNMENT_LEFT, text_width + 1.0, font_size, Color("40523e"))


func _create_residents(saved_world: Dictionary) -> void:
	var resident_states: Dictionary = saved_world.get("resident_states", {})
	for data in RESIDENTS:
		var resident := RESIDENT_SCRIPT.new() as HaeondongResident
		var same_home_count := 0
		for existing in residents:
			if existing.home == str(data.home):
				same_home_count += 1
		resident.configure(data, _resident_slot(str(data.home), same_home_count))
		var personality: Dictionary = RESIDENT_PERSONALITIES.get(resident.resident_id, {})
		resident.traits.assign(personality.get("traits", []))
		resident.values.assign(personality.get("values", []))
		resident.background = str(personality.get("background", ""))
		var sprite_path := "res://assets/" + resident.resident_id + ".png"
		if ResourceLoader.exists(sprite_path):
			resident.sprite_texture = PixelSprite.load_trimmed(sprite_path)
			resident.portrait_texture = PixelSprite.load_trimmed(sprite_path, 192)
		elif RESIDENT_PORTRAIT_INDICES.has(resident.resident_id):
			resident.sprite_texture = PixelSprite.load_atlas_region("res://assets/residents_atlas.png", int(RESIDENT_PORTRAIT_INDICES[resident.resident_id]), 4, 2)
			resident.portrait_texture = PixelSprite.load_atlas_region("res://assets/residents_atlas.png", int(RESIDENT_PORTRAIT_INDICES[resident.resident_id]), 4, 2, 192)
		if resident.sprite_texture != null:
			resident.sprite_size = resident.sprite_texture.get_size()
		var raw_state: Variant = resident_states.get(resident.resident_id, {})
		var state: Dictionary = raw_state if raw_state is Dictionary else {}
		resident.player_affinity = int(relationships.get(resident.resident_id, 0))
		resident.goal_progress = int(state.get("goal_progress", 0))
		resident.milestone_reached = bool(state.get("milestone_reached", false))
		resident.energy = float(state.get("energy", 82.0))
		resident.hunger = float(state.get("hunger", 30.0))
		resident.social_need = float(state.get("social_need", 42.0))
		resident.money = int(state.get("money", 50))
		resident.last_contact_day = int(state.get("last_contact_day", 0))
		resident.last_gift_day = int(state.get("last_gift_day", 0))
		resident.secret_shared_with_player = bool(state.get("secret_shared_with_player", false))
		resident.memories.assign(state.get("memories", []))
		for raw_rumor in state.get("rumors", []):
			if raw_rumor is Dictionary and str(raw_rumor.get("event_id", "")) != "" and str(raw_rumor.get("text", "")) != "":
				resident.rumors.append(raw_rumor.duplicate(true))
		add_child(resident)
		residents.append(resident)


func _create_player(saved_world: Dictionary) -> void:
	player = PLAYER_SCRIPT.new() as HaeondongPlayer
	player.name = "Player"
	player.sprite_texture = PixelSprite.load_trimmed("res://assets/player.png")
	if player.sprite_texture != null:
		player.sprite_size = player.sprite_texture.get_size()
	player.global_position = PLACES["골목"] + Vector2(4, 18)
	player.z_index = 20
	add_child(player)
	var saved_position: Vector2 = saved_world.get("player_position", player.global_position)
	player.global_position = saved_position


func _resident_slot(place: String, index: int) -> Vector2:
	var center: Vector2 = PLACES.get(place, PLACES["골목"])
	var offsets := [Vector2(-18, 16), Vector2(18, 16), Vector2(-2, 34), Vector2(-28, 30), Vector2(30, 32), Vector2(0, 4), Vector2(-34, 8), Vector2(35, 5), Vector2(-18, 44), Vector2(20, 45)]
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

	var story_box := _make_panel(root, Vector2(700, 16), Vector2(242, 130))
	story_label = _make_label("이웃들이 각자의 하루를 시작합니다.", 13, Color("465543"))
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.custom_minimum_size = Vector2(210, 54)
	story_box.add_child(_make_label("오늘의 흔적", 15, Color("314a39")))
	story_box.add_child(story_label)
	appointment_label = _make_label("약속 없음", 12, Color("68705a"))
	story_box.add_child(appointment_label)

	var hint_panel := _make_panel(root, Vector2(356, 16), Vector2(308, 54))
	var hint_row := HBoxContainer.new()
	hint_row.add_theme_constant_override("separation", 8)
	hint_panel.add_child(hint_row)
	interaction_label = _make_label("WASD 이동 · E 대화 · Esc 메뉴", 12, Color("52634e"))
	interaction_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_row.add_child(interaction_label)
	journal_button = Button.new()
	journal_button.text = "기록 J"
	journal_button.custom_minimum_size = Vector2(72, 34)
	_style_button(journal_button)
	journal_button.pressed.connect(_open_journal)
	hint_row.add_child(journal_button)

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
	modal_scrim = ColorRect.new()
	modal_scrim.color = Color(0.12, 0.16, 0.13, 0.42)
	modal_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_scrim.z_index = 45
	modal_scrim.visible = false
	root.add_child(modal_scrim)

	var dialogue_column := _make_panel(root, Vector2(130, 62), Vector2(700, 416))
	dialogue_panel = dialogue_column.get_parent() as PanelContainer
	dialogue_panel.visible = false
	dialogue_panel.z_index = 50
	dialogue_column.add_theme_constant_override("separation", 8)
	var speaker_row := HBoxContainer.new()
	speaker_row.add_theme_constant_override("separation", 16)
	dialogue_column.add_child(speaker_row)
	var portrait_column := VBoxContainer.new()
	portrait_column.add_theme_constant_override("separation", 4)
	speaker_row.add_child(portrait_column)
	var portrait_frame := PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(146, 184)
	var portrait_style := StyleBoxFlat.new()
	portrait_style.bg_color = Color("e2e8d6")
	portrait_style.border_color = Color("b8c8aa")
	portrait_style.set_border_width_all(2)
	portrait_style.set_corner_radius_all(8)
	portrait_frame.add_theme_stylebox_override("panel", portrait_style)
	portrait_column.add_child(portrait_frame)
	dialogue_portrait = TextureRect.new()
	dialogue_portrait.custom_minimum_size = Vector2(128, 160)
	dialogue_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dialogue_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dialogue_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait_frame.add_child(dialogue_portrait)
	dialogue_mood_label = _make_label("평온", 11, Color("5d7055"))
	dialogue_mood_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_column.add_child(dialogue_mood_label)
	var speaker_copy := VBoxContainer.new()
	speaker_copy.add_theme_constant_override("separation", 5)
	speaker_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speaker_row.add_child(speaker_copy)
	dialogue_name_label = _make_label("이웃", 20, Color("314a39"))
	speaker_copy.add_child(dialogue_name_label)
	dialogue_role_label = _make_label("오늘의 이야기", 12, Color("63705c"))
	speaker_copy.add_child(dialogue_role_label)
	dialogue_text = _make_label("", 16, Color("354536"))
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.custom_minimum_size = Vector2(480, 146)
	speaker_copy.add_child(dialogue_text)
	var dialogue_choices := GridContainer.new()
	dialogue_choices.columns = 2
	dialogue_choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_choices.add_theme_constant_override("h_separation", 8)
	dialogue_choices.add_theme_constant_override("v_separation", 5)
	dialogue_column.add_child(dialogue_choices)
	_add_dialogue_button(dialogue_choices, "안부를 묻는다", "ask")
	_add_dialogue_button(dialogue_choices, "좋아하는 것을 묻는다", "hobby")
	_add_dialogue_button(dialogue_choices, "동네 소식을 묻는다", "news")
	confide_button = _add_dialogue_button(dialogue_choices, "조심스러운 고민을 듣는다", "confide")
	gift_flower_button = _add_dialogue_button(dialogue_choices, "꽃다발을 선물한다", "gift_flower")
	gift_book_button = _add_dialogue_button(dialogue_choices, "책을 선물한다", "gift_book")
	_add_dialogue_button(dialogue_choices, "내일 만나자고 한다", "invite")
	_add_dialogue_button(dialogue_choices, "다음에 또 보기", "close")

	journal_panel = _make_panel(root, Vector2(190, 66), Vector2(580, 410)).get_parent() as PanelContainer
	journal_panel.visible = false
	journal_panel.z_index = 60
	var journal_column := VBoxContainer.new()
	journal_column.add_theme_constant_override("separation", 10)
	journal_panel.add_child(journal_column)
	journal_column.add_child(_make_label("해온동 생활 기록", 22, Color("314a39")))
	journal_text = _make_label("", 14, Color("465543"))
	journal_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journal_text.custom_minimum_size = Vector2(520, 470)
	var journal_scroll := ScrollContainer.new()
	journal_scroll.custom_minimum_size = Vector2(530, 270)
	journal_scroll.add_child(journal_text)
	journal_column.add_child(journal_scroll)
	sound_button = Button.new()
	sound_button.text = "효과음: 켬"
	sound_button.custom_minimum_size = Vector2(0, 34)
	_style_button(sound_button)
	sound_button.pressed.connect(_toggle_sound)
	journal_column.add_child(sound_button)
	var close_journal := Button.new()
	close_journal.text = "돌아가기  J / Esc"
	close_journal.custom_minimum_size = Vector2(0, 38)
	_style_button(close_journal)
	close_journal.pressed.connect(_close_journal)
	journal_column.add_child(close_journal)

	pause_panel = _make_panel(root, Vector2(300, 98), Vector2(360, 344)).get_parent() as PanelContainer
	pause_panel.visible = false
	pause_panel.z_index = 70
	var pause_column := VBoxContainer.new()
	pause_column.add_theme_constant_override("separation", 12)
	pause_panel.add_child(pause_column)
	pause_column.add_child(_make_label("잠시 쉬어 가기", 22, Color("314a39")))
	pause_column.add_child(_make_label("지금까지의 동네와 플레이 상태는 자동으로 저장돼요.", 13, Color("52634e")))
	var resume_button := Button.new()
	resume_button.text = "계속하기  Esc"
	resume_button.custom_minimum_size = Vector2(0, 42)
	_style_button(resume_button, true)
	resume_button.pressed.connect(_close_pause)
	pause_column.add_child(resume_button)
	var save_button := Button.new()
	save_button.text = "지금 저장하기"
	save_button.custom_minimum_size = Vector2(0, 42)
	_style_button(save_button)
	save_button.pressed.connect(_save_from_pause)
	pause_column.add_child(save_button)
	pause_sound_button = Button.new()
	pause_sound_button.text = "효과음: 켬"
	pause_sound_button.custom_minimum_size = Vector2(0, 42)
	_style_button(pause_sound_button)
	pause_sound_button.pressed.connect(_toggle_sound)
	pause_column.add_child(pause_sound_button)
	var quit_button := Button.new()
	quit_button.text = "저장하고 게임 종료"
	quit_button.custom_minimum_size = Vector2(0, 42)
	_style_button(quit_button)
	quit_button.pressed.connect(_quit_game)
	pause_column.add_child(quit_button)
	var help_from_pause := Button.new()
	help_from_pause.text = "플레이 도움말  F1"
	help_from_pause.custom_minimum_size = Vector2(0, 42)
	_style_button(help_from_pause)
	help_from_pause.pressed.connect(func() -> void: _open_help(true))
	pause_column.add_child(help_from_pause)

	help_panel = _make_panel(root, Vector2(220, 74), Vector2(520, 392)).get_parent() as PanelContainer
	help_panel.visible = false
	help_panel.z_index = 65
	var help_column := VBoxContainer.new()
	help_column.add_theme_constant_override("separation", 10)
	help_panel.add_child(help_column)
	help_column.add_child(_make_label("해온동에서 하루 보내기", 22, Color("314a39")))
	var help_scroll := ScrollContainer.new()
	help_scroll.custom_minimum_size = Vector2(480, 260)
	help_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	help_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	help_column.add_child(help_scroll)
	var help_body := _make_label("해야 할 일이나 정해진 엔딩은 없어요. 오늘 마음이 가는 일을 해보세요.\n\n걷기: WASD 또는 방향키로 이동하고, 지도를 눌러 그곳으로 걸어가요. 주민 가까이에서 E를 누르거나 주민을 누르면 대화할 수 있어요.\n\n생활: 카페에서 일하고 식사해요. 집에서 쉬고 도서관에서 책을 읽어요. 숫자 1~6 또는 화면 아래 버튼으로 행동을 고를 수 있어요. 장소에 도착해야 활동할 수 있어요.\n\n관계: 안부와 취향을 묻고, 이웃이 들은 동네 소식을 물어보세요. 충분히 가까워지면 조심스러운 고민을 들을 수 있어요. 서점에서 산 책이나 꽃집의 꽃을 선물하고 내일 약속을 제안해 보세요. 거절하거나 지나쳐도 이웃들은 자기 방식으로 하루를 이어갑니다.\n\n기록 J: 이웃의 바라는 일, 기억, 약속과 최근 동네 소식을 확인해요. Esc: 대화나 기록을 닫고 일시정지 메뉴를 열어요. F1: 이 도움말을 다시 엽니다. 세계와 플레이 상태는 자동 저장돼요.", 15, Color("465543"))
	help_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_body.custom_minimum_size = Vector2(460, 0)
	help_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help_scroll.add_child(help_body)
	var close_help := Button.new()
	close_help.text = "돌아가기  Esc / F1"
	close_help.custom_minimum_size = Vector2(0, 40)
	_style_button(close_help, true)
	close_help.pressed.connect(_close_help)
	help_column.add_child(close_help)


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


func _style_button(button: Button, primary: bool = false) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("71866a") if primary else Color("e9e0ca")
	normal.border_color = Color("4f6949") if primary else Color("c9bea5")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(7)
	normal.content_margin_left = 8.0
	normal.content_margin_right = 8.0
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("829779") if primary else Color("f4ebd8")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("5e7357") if primary else Color("d8cdb3")
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("ded8c9")
	disabled.border_color = Color("c9c3b6")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("fff8e8") if primary else Color("3d4d3a"))
	button.add_theme_color_override("font_hover_color", Color("fffaf0") if primary else Color("314331"))
	button.add_theme_color_override("font_pressed_color", Color("fffaf0") if primary else Color("314331"))
	button.add_theme_color_override("font_disabled_color", Color("827f73"))


func _add_action_button(parent: HBoxContainer, title: String, key: String, action: String) -> void:
	var button := Button.new()
	button.text = title + "  " + key
	button.custom_minimum_size = Vector2(138, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 14)
	_style_button(button, action == "talk")
	button.pressed.connect(func() -> void: _perform_action(action))
	parent.add_child(button)
	action_buttons.append(button)


func _add_dialogue_button(parent: Control, title: String, action: String) -> Button:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(0, 36)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 14)
	_style_button(button, action == "close")
	button.pressed.connect(func() -> void: _dialogue_action(action))
	parent.add_child(button)
	return button


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
				if barista.last_contact_day != day:
					_change_relationship(barista, 1)
					barista.last_contact_day = day
				_add_goal_progress(barista, 2, "플레이어가 카페에서 함께 일해 주었다.")
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
				if librarian.last_contact_day != day:
					_change_relationship(librarian, 1)
					librarian.last_contact_day = day
				_add_goal_progress(librarian, 5, "플레이어가 도서관에서 책을 읽었다.")
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
				"서점":
					var bookseller := _resident_by_id("yun")
					var book_price := 2 if bookseller != null and bookseller.milestone_reached else 5
					if money < book_price:
						_add_event("책 한 권을 고르려면 " + str(book_price) + "원이 필요해요.")
						return
					elapsed = 45
					money -= book_price
					inventory["책"] = int(inventory.get("책", 0)) + 1
					if book_price == 2:
						_add_event("윤의 책 교환 서가에서 책을 바꿔왔어요. 가방에 한 권 넣었어요.")
					else:
						_add_event("서점에서 마음에 드는 책을 샀어요. 이웃에게 선물할 수도 있어요.")
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
					inventory["꽃다발"] = int(inventory.get("꽃다발", 0)) + 1
					_add_event("계절 꽃을 골라 작은 꽃다발을 샀어요. 누군가에게 건넬 수 있어요.")
				"공방", "도서관", "카페", "학교", "우체국":
					elapsed = 45
					energy = maxf(0.0, energy - 3.0)
					var neighbor := _resident_at_place(place)
					var barista := _resident_by_id("minjae")
					var librarian := _resident_by_id("yerin")
					if place == "카페" and barista.milestone_reached:
						elapsed = 90
						_add_event("민재의 저녁 음악 모임에 들러 따뜻한 노래를 들었어요.")
						if neighbor != null:
							_add_memory(neighbor, "플레이어가 내 음악 모임에 들러 함께 시간을 보냈다.")
					elif place == "도서관" and librarian.milestone_reached:
						elapsed = 60
						_add_event("예린이 만든 동네 책 목록을 함께 읽었어요.")
						if neighbor != null:
							_add_memory(neighbor, "플레이어가 동네 책 목록을 함께 읽었다.")
					elif neighbor != null:
						_add_goal_progress(neighbor, 3, "플레이어가 " + place + "에서 내 계획을 도왔다.")
						_add_event(neighbor.resident_name + _particle(neighbor.resident_name, "과", "와") + " " + place + "에서 각자의 계획을 조금 도왔어요.")
					else:
						_add_event(place + "에서 잠시 시간을 보냈어요.")
				_:
					_add_event("먼저 지도를 눌러 장소를 둘러보세요.")
					return
		_:
			return

	if elapsed > 0:
		_advance_time(elapsed)
		_save_world()
		_play_chime()
	_update_hud()


func _interact_nearby() -> void:
	var closest: HaeondongResident
	var closest_distance := 54.0
	for resident in residents:
		if not resident.visible:
			continue
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
	modal_scrim.visible = true
	dialogue_portrait.texture = resident.portrait_texture if resident.portrait_texture != null else resident.sprite_texture
	dialogue_name_label.text = resident.resident_name
	dialogue_role_label.text = resident.role + " · " + resident.location
	_set_dialogue_mood("편안")
	_update_gift_buttons()
	player.set_physics_process(false)
	var greeting := "“안녕하세요. 저는 " + resident.resident_name + _particle(resident.resident_name, "이에요", "예요") + ". 오늘은 " + resident.location + "에 있어요.”"
	if resident.player_affinity >= 2:
		greeting = "“" + resident.resident_name + _particle(resident.resident_name, "이에요", "예요") + " 다시 만나 반가워요. 지난번 이야기 기억나요.”"
	if not resident.traits.is_empty():
		greeting += "\n성격: " + " · ".join(resident.traits)
	if not resident.memories.is_empty():
		greeting += "\n\n지난번에는 " + resident.memories[0] + ""
	if resident.milestone_reached:
		dialogue_text.text = greeting + "\n\n" + _milestone_title(resident)
	else:
		dialogue_text.text = greeting + "\n\n요즘 바라는 일은 " + resident.goal + "예요. (진척 " + str(resident.goal_progress) + "%)"
	interaction_label.text = resident.resident_name + _particle(resident.resident_name, "과", "와") + " 이야기하고 있어요 · Esc로 닫기"
	_update_confide_button(resident)


func _update_confide_button(resident: HaeondongResident) -> void:
	confide_button.visible = resident.player_affinity >= 6 and not resident.private_worry.is_empty()
	confide_button.disabled = resident.secret_shared_with_player
	confide_button.text = "이미 들은 고민" if resident.secret_shared_with_player else "조심스러운 고민을 듣는다"


func _set_dialogue_mood(mood: String) -> void:
	if dialogue_mood_label == null or dialogue_portrait == null:
		return
	dialogue_mood_label.text = mood
	dialogue_portrait.pivot_offset = dialogue_portrait.custom_minimum_size / 2.0
	dialogue_portrait.scale = Vector2.ONE
	var portrait_tween := create_tween()
	portrait_tween.tween_property(dialogue_portrait, "scale", Vector2(1.06, 1.06), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	portrait_tween.tween_property(dialogue_portrait, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	match mood:
		"미소": dialogue_portrait.modulate = Color(1.0, 1.0, 0.91)
		"관심": dialogue_portrait.modulate = Color(0.91, 1.0, 0.88)
		"궁금": dialogue_portrait.modulate = Color(0.88, 0.96, 1.0)
		"걱정", "믿음": dialogue_portrait.modulate = Color(0.92, 0.91, 1.0)
		"기쁨": dialogue_portrait.modulate = Color(1.0, 0.87, 0.79)
		_: dialogue_portrait.modulate = Color.WHITE


func _daily_small_talk(resident: HaeondongResident) -> String:
	var lines: Array = DAILY_SMALL_TALK.get(resident.resident_id, [])
	if lines.is_empty():
		return "오늘도 동네의 작은 일들을 천천히 살펴보고 있어요."
	var hour := floori(float(game_minute) / 60.0)
	var part := 0 if hour >= 6 and hour < 12 else (1 if hour >= 12 and hour < 18 else 2)
	return str(lines[part])


func _dialogue_action(action: String) -> void:
	if dialogue_resident == null:
		return
	var resident := dialogue_resident
	var moods := {"ask":"미소", "hobby":"관심", "news":"궁금", "confide":"믿음", "invite":"기대", "gift_flower":"기쁨", "gift_book":"기쁨"}
	_set_dialogue_mood(str(moods.get(action, "편안")))
	match action:
		"ask":
			var first_contact_today := resident.last_contact_day != day
			if first_contact_today:
				_change_relationship(resident, 1)
				resident.last_contact_day = day
			resident.social_need = maxf(0.0, resident.social_need - 12.0)
			if first_contact_today:
				_add_memory(resident, "플레이어가 먼저 안부를 물었다.")
				dialogue_text.text = "“" + _daily_small_talk(resident) + "”\n\n" + resident.background + "\n오늘의 안부가 " + resident.resident_name + "의 하루에 작은 흔적으로 남았어요."
				_add_event(resident.resident_name + _particle(resident.resident_name, "과", "와") + " 안부를 나눴어요.")
			else:
				dialogue_text.text = "“아까 나눈 이야기 덕분에 마음이 한결 느긋해졌어요. 오늘은 이 여운을 조금 더 간직하고 싶네요.”"
		"hobby":
			var favorite_list := ", ".join(resident.preferences)
			var value_list := ", ".join(resident.values)
			dialogue_text.text = "“요즘은 " + favorite_list + _particle(favorite_list, "을", "를") + " 즐겨요. 제게는 " + value_list + _particle(value_list, "이", "가") + " 소중하거든요.”"
			if resident.last_contact_day != day:
				_change_relationship(resident, 1)
				resident.last_contact_day = day
				_add_memory(resident, "플레이어에게 좋아하는 것을 이야기했다.")
				_add_event(resident.resident_name + _particle(resident.resident_name, "이", "가") + " 좋아하는 것을 알려줬어요.")
		"news":
			if resident.rumors.is_empty():
				dialogue_text.text = "“아직 새로 들은 동네 소식은 없어요. 요즘은 다들 자기 일을 차분히 하고 있답니다.”"
			else:
				var rumor: Dictionary = resident.rumors[0]
				var source := _resident_by_id(str(rumor.get("heard_from", "")))
				var source_name := source.resident_name if source != null else "이웃"
				var certainty := float(rumor.get("confidence", 0.5))
				var preface := "“" + source_name + "에게 들었는데, " if certainty >= 0.7 else "“" + source_name + "에게 들은 이야기예요. 정확한지는 잘 모르겠지만, "
				dialogue_text.text = preface + str(rumor.get("text", "")) + "”"
				_add_memory(resident, "플레이어에게 내가 들은 동네 소식을 전했다.")
				_add_event(resident.resident_name + "에게 동네 소식을 들었어요.")
		"confide":
			if resident.player_affinity < 6 or resident.secret_shared_with_player:
				dialogue_text.text = "“아직은 마음속 이야기를 꺼내기 조금 어려워요.”"
			else:
				resident.secret_shared_with_player = true
				_add_memory(resident, "플레이어에게 조심스러운 고민을 털어놓았다. " + resident.private_worry)
				dialogue_text.text = "“사실은 " + resident.private_worry + ". 아직 다른 이웃에게는 말하지 않았어요.”\n\n이 이야기는 두 사람 사이에만 남아요."
				_add_event(resident.resident_name + _particle(resident.resident_name, "이", "가") + " 조심스러운 고민을 들려줬어요.")
		"invite":
			if resident.player_affinity >= 2 and not _has_appointment(resident.resident_id):
				if _accepts_invitation(resident):
					var meeting_place := _location_of(player.global_position)
					if meeting_place == "골목":
						meeting_place = "공원"
					appointments.append({"resident_id": resident.resident_id, "day": day + 1, "place": meeting_place, "resolved": false})
					_add_memory(resident, "플레이어와 내일 " + meeting_place + "에서 만나기로 했다.")
					dialogue_text.text = "“좋아요. 내일 오후 다섯 시에 " + meeting_place + "에서 만나요.”\n\n내일 저녁 여섯 시 전까지 그곳에 가면 만날 수 있어요."
					_add_event(resident.resident_name + _particle(resident.resident_name, "과", "와") + " 내일 " + meeting_place + "에서 만나기로 했어요.")
				else:
					dialogue_text.text = "“내일은 조금 지쳐 있거나 일정이 있어요. 오늘은 약속을 잡지 않는 게 좋겠어요.”\n\n마음이 바뀌어도 관계가 나빠지지는 않았어요."
					_add_memory(resident, "플레이어의 만남 제안을 받았지만 내일은 쉬거나 다른 일을 하기로 했다.")
					_add_event(resident.resident_name + _particle(resident.resident_name, "이", "가") + " 내일 약속은 정중히 미뤘어요.")
			else:
				if _has_appointment(resident.resident_id):
					dialogue_text.text = "“우리 내일 만나기로 했잖아요. 약속 장소에서 봐요.”"
				else:
					dialogue_text.text = "“아직은 조금 어색하네요. 다음에 더 이야기 나누고 생각해 볼게요.”"
		"gift_flower":
			_give_gift(resident, "꽃다발")
		"gift_book":
			_give_gift(resident, "책")
		"close":
			_close_dialogue()
	_save_world()
	_update_hud()
	if action != "close":
		_play_chime()
	if dialogue_panel.visible:
		_update_confide_button(dialogue_resident)
	if journal_panel.visible:
		_update_journal()


func _give_gift(resident: HaeondongResident, item: String) -> void:
	if resident.last_gift_day == day:
		dialogue_text.text = "“오늘은 이미 마음을 받았어요. 다음에 또 이야기해요.”"
		return
	if int(inventory.get(item, 0)) <= 0:
		dialogue_text.text = "“선물하고 싶은 마음은 고마워요. 먼저 " + item + "을 준비해 주세요.”"
		return
	inventory[item] = int(inventory[item]) - 1
	resident.last_gift_day = day
	var affinity_gain := 2
	if item == "꽃다발" and resident.resident_id == "yerin":
		affinity_gain = 3
	if item == "책" and (resident.resident_id == "yun" or resident.resident_id == "yerin"):
		affinity_gain = 3
	_change_relationship(resident, affinity_gain)
	_add_memory(resident, "플레이어에게 " + item + "을 선물로 받았다.")
	if item == "책" and resident.resident_id == "yun":
		_add_goal_progress(resident, 6, "플레이어가 책을 선물해 책 교환 서가 준비를 도왔다.")
	elif item == "꽃다발" and resident.resident_id == "yerin":
		_add_goal_progress(resident, 5, "플레이어가 꽃을 건네 도서관의 식물을 함께 돌봤다.")
	dialogue_text.text = "“" + item + " 선물 고마워요. 오래 기억할게요.”\n\n" + resident.resident_name + _particle(resident.resident_name, "이", "가") + " 선물을 기억했어요."
	_add_event(resident.resident_name + _particle(resident.resident_name, "이", "가") + " " + item + "을 선물로 받았어요.")
	_update_gift_buttons()


func _update_gift_buttons() -> void:
	if dialogue_resident == null:
		return
	var already_gifted := dialogue_resident.last_gift_day == day
	gift_flower_button.text = "꽃다발 선물  ×" + str(inventory.get("꽃다발", 0))
	gift_book_button.text = "책 선물  ×" + str(inventory.get("책", 0))
	gift_flower_button.disabled = already_gifted or int(inventory.get("꽃다발", 0)) <= 0
	gift_book_button.disabled = already_gifted or int(inventory.get("책", 0)) <= 0


func _setup_sound() -> void:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	var sample_count := 3969
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for index in sample_count:
		var seconds := float(index) / float(stream.mix_rate)
		var envelope := exp(-18.0 * seconds)
		var tone := sin(TAU * 587.33 * seconds) + sin(TAU * 880.0 * seconds) * 0.34
		data.encode_s16(index * 2, roundi(clampf(tone * envelope * 4200.0, -32767.0, 32767.0)))
	stream.data = data
	chime_player = AudioStreamPlayer.new()
	chime_player.name = "SoftChime"
	chime_player.stream = stream
	chime_player.volume_db = -12.0
	add_child(chime_player)
	sound_button.text = "효과음: 켬" if sound_enabled else "효과음: 끔"
	pause_sound_button.text = sound_button.text


func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	sound_button.text = "효과음: 켬" if sound_enabled else "효과음: 끔"
	pause_sound_button.text = sound_button.text
	_save_world()
	if sound_enabled:
		_play_chime()


func _play_chime() -> void:
	if sound_enabled and chime_player != null and not chime_player.playing:
		chime_player.play()


func _close_dialogue() -> void:
	dialogue_panel.visible = false
	modal_scrim.visible = false
	dialogue_resident = null
	player.set_physics_process(true)
	_update_hud()


func _open_journal() -> void:
	if dialogue_panel.visible:
		_close_dialogue()
	pending_resident_id = ""
	journal_panel.visible = true
	modal_scrim.visible = true
	player.set_physics_process(false)
	interaction_label.text = "생활 기록을 살펴보고 있어요 · J 또는 Esc로 돌아가기"
	_update_journal()


func _close_journal() -> void:
	journal_panel.visible = false
	modal_scrim.visible = false
	player.set_physics_process(true)
	_update_hud()


func _open_pause() -> void:
	if journal_panel.visible:
		_close_journal()
	if dialogue_panel.visible:
		_close_dialogue()
	pending_resident_id = ""
	pause_panel.visible = true
	modal_scrim.visible = true
	player.set_physics_process(false)


func _close_pause() -> void:
	pause_panel.visible = false
	modal_scrim.visible = false
	player.set_physics_process(true)


func _open_help(from_pause: bool = false) -> void:
	if dialogue_panel.visible:
		_close_dialogue()
	if journal_panel.visible:
		_close_journal()
	help_return_to_pause = from_pause or pause_panel.visible
	pause_panel.visible = false
	help_panel.visible = true
	modal_scrim.visible = true
	player.set_physics_process(false)


func _close_help() -> void:
	help_panel.visible = false
	if help_return_to_pause:
		pause_panel.visible = true
		modal_scrim.visible = true
		player.set_physics_process(false)
	else:
		modal_scrim.visible = false
		player.set_physics_process(true)
	help_return_to_pause = false


func _save_from_pause() -> void:
	_add_event("동네의 현재 모습을 저장했어요.")
	_save_world()


func _quit_game() -> void:
	_save_world()
	get_tree().quit()


func _update_journal() -> void:
	var lines := PackedStringArray()
	lines.append("" + str(day) + "일째 · " + _season_name() + " · " + _location_of(player.global_position))
	lines.append("가진 돈 " + str(money) + "원   기운 " + str(roundi(energy)) + "   허기 " + str(roundi(hunger)) + "%")
	lines.append("가방: 꽃다발 " + str(inventory.get("꽃다발", 0)) + "개 · 책 " + str(inventory.get("책", 0)) + "권")
	lines.append("")
	lines.append("— 알고 지내는 이웃 —")
	for resident in residents:
		var closeness := "처음 만난 사이" if resident.player_affinity < 2 else ("편한 이웃" if resident.player_affinity < 8 else "가까운 친구")
		lines.append(resident.resident_name + " · " + resident.role + " · 지금 " + resident.location)
		lines.append("  관계: " + closeness + " (" + str(resident.player_affinity) + ")")
		lines.append("  바라는 일: " + resident.goal + " · " + str(resident.goal_progress) + "%")
		if resident.milestone_reached:
			lines.append("  이룬 일: " + _milestone_title(resident))
		if not resident.memories.is_empty():
			lines.append("  기억: " + str(resident.memories[0]))
	lines.append("")
	lines.append("— 예정된 약속 —")
	var active_appointment := false
	for appointment in appointments:
		if bool(appointment.get("resolved", false)):
			continue
		var appointment_day := int(appointment.get("day", day))
		var name := _resident_by_id(str(appointment.get("resident_id", "")))
		lines.append(str(appointment_day) + "일째 오후 5시 · " + str(appointment.get("place", "공원")) + "에서 " + (name.resident_name if name != null else "이웃") + "와 만나기로 했어요.")
		active_appointment = true
	if not active_appointment:
		lines.append("아직 약속이 없어요. 가까워진 이웃에게 내일 만나자고 해보세요.")
	lines.append("")
	lines.append("— 최근 동네 소식 —")
	for event_text in events.slice(0, 5):
		lines.append("· " + event_text)
	journal_text.text = "\n".join(lines)
	sound_button.text = "효과음: 켬" if sound_enabled else "효과음: 끔"


func _handle_world_tap(at: Vector2) -> void:
	if (dialogue_panel != null and dialogue_panel.visible) or (journal_panel != null and journal_panel.visible) or (pause_panel != null and pause_panel.visible):
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
		if not resident.visible:
			continue
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


func _particle(name: String, with_final: String, without_final: String) -> String:
	if name.is_empty():
		return without_final
	var codepoint := name.unicode_at(name.length() - 1)
	if codepoint < 0xAC00 or codepoint > 0xD7A3:
		return without_final
	return with_final if (codepoint - 0xAC00) % 28 != 0 else without_final


func _resident_at_place(place: String) -> HaeondongResident:
	for resident in residents:
		if resident.visible and resident.location == place:
			return resident
	return null


func _change_relationship(resident: HaeondongResident, amount: int) -> void:
	resident.player_affinity = mini(100, resident.player_affinity + amount)
	relationships[resident.resident_id] = resident.player_affinity
	_add_event(resident.resident_name + _particle(resident.resident_name, "과", "와") + " 조금 더 편하게 이야기하게 됐어요.")


func _add_memory(resident: HaeondongResident, memory: String) -> void:
	resident.memories.push_front(memory)
	if resident.memories.size() > 20:
		resident.memories.resize(20)


func _add_goal_progress(resident: HaeondongResident, amount: int, memory: String = "") -> void:
	if amount <= 0 or resident.milestone_reached:
		return
	resident.goal_progress = mini(100, resident.goal_progress + amount)
	if not memory.is_empty():
		_add_memory(resident, memory)
	if resident.goal_progress >= 100:
		resident.milestone_reached = true
		_add_memory(resident, "오래 바라던 일을 동네 사람들과 함께 이뤘다.")
		_add_event(_milestone_title(resident))


func _milestone_title(resident: HaeondongResident) -> String:
	match resident.resident_id:
		"yun":
			return "윤이 책방에 작은 책 교환 서가를 열었어요. 첫 책을 함께 고를 수 있어요."
		"minjae":
			return "민재가 카페에서 작은 음악 모임을 시작했어요. 저녁마다 노래가 들려요."
		"yerin":
			return "예린이 동네 사람들과 함께 읽을 책 목록을 완성했어요."
		"sua":
			return "수아가 동네 꽃으로 작은 전시를 열었어요."
		"dohyeon":
			return "도현이 오래된 편지의 주인을 찾아 전했어요."
		"gaeun":
			return "가은이 이웃과 함께 쓰는 수리 작업대를 만들었어요."
		"junho":
			return "준호가 남는 채소를 이웃들과 나눴어요."
		"daeun":
			return "다은이 누구나 참여할 수 있는 연주 모임을 열었어요."
		"taeo":
			return "태오가 동네 사람들을 위한 저녁 수업을 시작했어요."
		"somin":
			return "소민이 오래 미뤄 둔 번역 원고를 마무리했어요."
		_:
			return resident.resident_name + _particle(resident.resident_name, "이", "가") + " 오래 바라던 일을 이뤘어요."


func _has_appointment(resident_id: String) -> bool:
	for appointment in appointments:
		if str(appointment.get("resident_id", "")) == resident_id and not bool(appointment.get("resolved", false)):
			return true
	return false


func _accepts_invitation(resident: HaeondongResident) -> bool:
	if resident.energy < 25.0 or resident.social_need < 15.0:
		return false
	var resident_index := residents.find(resident)
	var willingness := clampi(resident.player_affinity + floori(resident.social_need / 30.0), 1, 5)
	var roll := posmod(day * 7 + resident_index * 3 + floori(resident.energy / 30.0), 5)
	return roll < willingness


func _initialize_connections(saved_world: Dictionary) -> void:
	var saved_connections: Dictionary = saved_world.get("connections", {})
	for resident in residents:
		resident.connections = saved_connections.get(resident.resident_id, {}).duplicate(true)
	var initial_links := [
		["yun", "yerin", 22], ["yun", "minjae", 12], ["minjae", "yerin", 8],
		["sua", "yerin", 18], ["sua", "junho", 20], ["dohyeon", "sua", 14],
		["gaeun", "dohyeon", 10], ["junho", "minjae", 16], ["daeun", "minjae", 25],
		["taeo", "yerin", 20], ["somin", "taeo", 9], ["somin", "yun", 7],
		["gaeun", "junho", 11], ["daeun", "taeo", 8], ["somin", "yerin", 13]
	]
	for pair in initial_links:
		var left := _resident_by_id(pair[0])
		var right := _resident_by_id(pair[1])
		if left != null and right != null:
			if not left.connections.has(right.resident_id):
				left.connections[right.resident_id] = pair[2]
			if not right.connections.has(left.resident_id):
				right.connections[left.resident_id] = pair[2]


func _initialize_rumors() -> void:
	for data in STARTING_RUMORS:
		var listener := _resident_by_id(str(data.listener))
		if listener == null:
			continue
		var event_id := "goal_" + str(data.subject)
		var already_known := false
		for rumor in listener.rumors:
			already_known = already_known or str(rumor.get("event_id", "")) == event_id
		if not already_known:
			listener.rumors.append({"event_id": event_id, "subject_id": data.subject, "text": data.text, "heard_from": data.source, "confidence": 0.85, "day": 1})


func _spread_rumor(speaker: HaeondongResident, listener: HaeondongResident) -> bool:
	for rumor in speaker.rumors:
		var confidence := float(rumor.get("confidence", 0.0)) - 0.12
		if confidence < 0.4:
			continue
		var event_id := str(rumor.get("event_id", ""))
		var already_known := false
		for known_rumor in listener.rumors:
			already_known = already_known or str(known_rumor.get("event_id", "")) == event_id
		if already_known:
			continue
		var passed_rumor := rumor.duplicate(true)
		passed_rumor["confidence"] = snappedf(confidence, 0.01)
		passed_rumor["heard_from"] = speaker.resident_id
		passed_rumor["day"] = day
		listener.rumors.push_front(passed_rumor)
		if listener.rumors.size() > 20:
			listener.rumors.resize(20)
		_add_memory(listener, speaker.resident_name + _particle(speaker.resident_name, "에게", "에게") + "서 " + str(rumor.get("text", "동네 소식")) + "을 들었다.")
		return true
	return false


func _meeting_place_for(resident_id: String, date: int) -> String:
	for appointment in appointments:
		if str(appointment.get("resident_id", "")) == resident_id and int(appointment.get("day", -1)) == date and not bool(appointment.get("resolved", false)):
			return str(appointment.get("place", "공원"))
	return ""


func _advance_time(minutes: int) -> void:
	if minutes > 10:
		var remaining_minutes := minutes
		while remaining_minutes > 0:
			var step := mini(10, remaining_minutes)
			_advance_time(step)
			remaining_minutes -= step
		return
	var old_absolute_time := (day - 1) * DAY_MINUTES + game_minute
	var old_day := day
	var old_hour := floori(float(game_minute) / 60.0)
	game_minute += minutes
	while game_minute >= DAY_MINUTES:
		game_minute -= DAY_MINUTES
		day += 1
		last_paid_day = 0
		_add_event("" + str(day) + "일째 아침이 왔어요.")
	var hour := floori(float(game_minute) / 60.0)
	if hour != old_hour or day != old_day:
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
	var new_absolute_time := (day - 1) * DAY_MINUTES + game_minute
	_resolve_appointments(old_absolute_time, new_absolute_time)
	if hour >= 20 and last_society_day != day:
		_run_evening_society()
	if hour != old_hour or day != old_day:
		queue_redraw()
		_save_world()


func _update_daily_schedule() -> void:
	var hour := floori(float(game_minute) / 60.0)
	for index in residents.size():
		var resident: HaeondongResident = residents[index]
		resident.visible = hour >= 6 and hour < 22
		var place := resident.home
		var shift: Vector2i = WORK_SHIFTS.get(resident.resident_id, Vector2i(8, 17))
		if hour >= shift.x and hour < shift.y:
			place = resident.workplace
		elif hour >= 16 and hour < 21 and not resident.schedule.is_empty():
			place = resident.schedule[(day - 1 + index) % resident.schedule.size()]
		var appointment_place := _meeting_place_for(resident.resident_id, day)
		if not appointment_place.is_empty() and hour >= 15 and hour < 19:
			place = appointment_place
		var slot := 0
		for preceding_index in range(index):
			if residents[preceding_index].target_location == place:
				slot += 1
		resident.set_destination(place, _resident_slot(place, slot))

	if hour >= 17 and hour < 21 and last_paid_day != day:
		for resident in residents:
			resident.money += resident.daily_wage
		last_paid_day = day


func _resolve_appointments(previous_time: int, current_time: int) -> void:
	for appointment in appointments:
		if bool(appointment.get("resolved", false)):
			continue
		var appointment_day := int(appointment.get("day", 0))
		var due_time := (appointment_day - 1) * DAY_MINUTES + 18 * 60
		if due_time <= previous_time or due_time > current_time:
			continue
		var resident := _resident_by_id(str(appointment.get("resident_id", "")))
		var place := str(appointment.get("place", "공원"))
		var player_arrived := _location_of(player.global_position) == place
		var resident_arrived := resident != null and resident.location == place
		appointment["resolved"] = true
		if player_arrived and resident_arrived:
			_add_event(resident.resident_name + _particle(resident.resident_name, "이", "가") + " " + place + "에서 기다리고 있었어요. 함께 저녁 산책을 했어요.")
			_add_memory(resident, "플레이어와 " + place + "에서 만나 저녁 시간을 보냈다.")
			resident.social_need = maxf(0.0, resident.social_need - 18.0)
			_change_relationship(resident, 2)
		elif resident != null:
			_add_event(resident.resident_name + _particle(resident.resident_name, "은", "는") + " " + place + "에서 한동안 기다리다 먼저 돌아갔어요.")
			_add_memory(resident, "약속 장소에서 기다렸지만 플레이어를 만나지 못했다.")
			resident.player_affinity = maxi(0, resident.player_affinity - 1)
			relationships[resident.resident_id] = resident.player_affinity


func _run_evening_society() -> void:
	last_society_day = day
	for resident in residents:
		if resident.energy >= 25.0:
			_add_goal_progress(resident, 2)
	var pair: Array[HaeondongResident] = []
	for first_index in residents.size():
		for second_index in range(first_index + 1, residents.size()):
			var first: HaeondongResident = residents[first_index]
			var second: HaeondongResident = residents[second_index]
			if first.location == second.location and (first.location != first.home or second.location != second.home) and first.social_need >= 35.0 and second.social_need >= 35.0:
				if (day * 7 + first_index * 3 + second_index) % 4 != 0:
					pair = [first, second]
					break
		if not pair.is_empty():
			break
	if pair.size() == 2:
		var first := pair[0]
		var second := pair[1]
		var moments: Array[String] = ["퇴근길에 동네의 오래된 가게 이야기를 나눴다.", "요즘 즐겨 듣는 노래를 서로 추천했다.", "각자 마음에 둔 작은 계획을 털어놓았다."]
		var moment: String = moments[(day - 1) % moments.size()]
		_add_memory(first, second.resident_name + _particle(second.resident_name, "과", "와") + " " + moment)
		_add_memory(second, first.resident_name + _particle(first.resident_name, "과", "와") + " " + moment)
		first.social_need = maxf(0.0, first.social_need - 10.0)
		second.social_need = maxf(0.0, second.social_need - 10.0)
		first.connections[second.resident_id] = mini(100, int(first.connections.get(second.resident_id, 0)) + 1)
		second.connections[first.resident_id] = mini(100, int(second.connections.get(first.resident_id, 0)) + 1)
		_add_event(first.resident_name + _particle(first.resident_name, "과", "와") + " " + second.resident_name + _particle(second.resident_name, "이", "가") + " " + first.location + "에서 이야기를 나눴어요.")
		if day % 3 == 0:
			var rumor_spread := _spread_rumor(first, second)
			if not rumor_spread:
				rumor_spread = _spread_rumor(second, first)
			if rumor_spread:
				_add_event("저녁 대화에서 들은 이야기가 한 이웃에게 전해졌어요.")
	else:
		_add_event("저녁이 조용히 흘렀어요. 이웃들은 각자의 계획을 조금씩 이어갔어요.")


func _update_interaction_hint() -> void:
	if dialogue_panel.visible:
		return
	var closest: HaeondongResident
	var closest_distance := 54.0
	for resident in residents:
		if not resident.visible:
			continue
		var distance := player.global_position.distance_to(resident.global_position)
		if distance < closest_distance:
			closest = resident
			closest_distance = distance
	if closest != null:
		interaction_label.text = "E: " + closest.resident_name + _particle(closest.resident_name, "과", "와") + " 대화"
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
	if appointment_label != null:
		appointment_label.text = _next_appointment_text()
	if story_label != null and not events.is_empty():
		story_label.text = "\n".join(events.slice(0, 3))


func _next_appointment_text() -> String:
	for appointment in appointments:
		if bool(appointment.get("resolved", false)):
			continue
		var when := "오늘" if int(appointment.get("day", 0)) == day else "내일"
		return when + " 오후 5시 · " + str(appointment.get("place", "공원")) + "에서 약속"
	return "약속 없음"


func _season_name() -> String:
	return ["봄", "여름", "가을", "겨울"][floori(float(day - 1) / 7.0) % 4]


func _add_event(text: String) -> void:
	events.push_front(text)
	if events.size() > 12:
		events.resize(12)
	if story_label != null:
		story_label.text = "\n".join(events.slice(0, 3))


func _load_world() -> Dictionary:
	var config := ConfigFile.new()
	var primary_valid := config.load(save_path) == OK and _is_valid_save_file(config)
	if not primary_valid:
		var backup_valid := config.load(save_path + ".bak") == OK and _is_valid_save_file(config)
		if not backup_valid:
			return {}
		if config.save(save_path) != OK:
			push_warning("기본 저장 파일은 복원하지 못했지만 백업 상태를 불러왔어요.")
	var saved_at := int(config.get_value("meta", "last_saved_unix", 0))
	if saved_at > 0:
		var elapsed_seconds := maxi(0, int(Time.get_unix_time_from_system()) - saved_at)
		offline_minutes_to_simulate = mini(1440, floori(float(elapsed_seconds) / 60.0))
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
		for saved_event in saved_events:
			if saved_event is String:
				events.append(saved_event)
	var saved_residents: Variant = config.get_value("world", "residents", {})
	var saved_inventory: Variant = config.get_value("player", "inventory", {})
	if saved_inventory is Dictionary:
		for item in inventory:
			inventory[item] = maxi(0, int(saved_inventory.get(item, 0)))
	var saved_appointments: Variant = config.get_value("world", "appointments", [])
	if saved_appointments is Array:
		for saved_appointment in saved_appointments:
			if saved_appointment is Dictionary:
				appointments.append(saved_appointment.duplicate(true))
	last_society_day = int(config.get_value("world", "last_society_day", 0))
	sound_enabled = bool(config.get_value("settings", "sound_enabled", true))
	var saved_connections: Variant = config.get_value("world", "connections", {})
	return {
		"player_position": Vector2(float(config.get_value("player", "x", 364.0)), float(config.get_value("player", "y", 221.0))),
		"resident_states": saved_residents if saved_residents is Dictionary else {},
		"connections": saved_connections if saved_connections is Dictionary else {}
	}


func _is_valid_save_file(config: ConfigFile) -> bool:
	if not config.has_section_key("world", "day") or not config.has_section_key("world", "minute") or not config.has_section_key("player", "money"):
		return false
	var saved_day := int(config.get_value("world", "day", 0))
	var saved_minute := int(config.get_value("world", "minute", -1))
	var saved_money := int(config.get_value("player", "money", -1))
	return saved_day >= 1 and saved_minute >= 0 and saved_minute < DAY_MINUTES and saved_money >= 0


func _save_world() -> void:
	if player == null:
		return
	var config := ConfigFile.new()
	config.set_value("world", "day", day)
	config.set_value("world", "minute", game_minute)
	config.set_value("world", "last_paid_day", last_paid_day)
	config.set_value("world", "last_society_day", last_society_day)
	config.set_value("world", "events", events)
	config.set_value("world", "appointments", appointments)
	config.set_value("meta", "last_saved_unix", int(Time.get_unix_time_from_system()))
	config.set_value("settings", "sound_enabled", sound_enabled)
	var resident_states := {}
	var saved_connections := {}
	for resident in residents:
		resident_states[resident.resident_id] = {
			"goal_progress": resident.goal_progress,
			"milestone_reached": resident.milestone_reached,
			"energy": resident.energy,
			"hunger": resident.hunger,
			"social_need": resident.social_need,
			"money": resident.money,
			"last_contact_day": resident.last_contact_day,
			"last_gift_day": resident.last_gift_day,
			"secret_shared_with_player": resident.secret_shared_with_player,
			"rumors": resident.rumors.slice(0, 20),
			"memories": resident.memories.slice(0, 20)
		}
		saved_connections[resident.resident_id] = resident.connections
	config.set_value("world", "residents", resident_states)
	config.set_value("world", "connections", saved_connections)
	config.set_value("player", "x", player.global_position.x)
	config.set_value("player", "y", player.global_position.y)
	config.set_value("player", "money", money)
	config.set_value("player", "energy", energy)
	config.set_value("player", "hunger", hunger)
	config.set_value("player", "inventory", inventory)
	config.set_value("player", "relationships", relationships)
	var temp_path := save_path + ".tmp"
	if config.save(temp_path) != OK:
		return
	var absolute_path := ProjectSettings.globalize_path(save_path)
	var backup_path := ProjectSettings.globalize_path(save_path + ".bak")
	if FileAccess.file_exists(save_path):
		if DirAccess.copy_absolute(absolute_path, backup_path) != OK:
			return
		if DirAccess.remove_absolute(absolute_path) != OK:
			return
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), absolute_path)
	if rename_error != OK:
		_add_event("저장 파일 교체에 실패했어요. 이전 저장본은 보관되어 있어요.")


func _apply_offline_time() -> void:
	if offline_minutes_to_simulate <= 0:
		return
	var minutes_to_apply := offline_minutes_to_simulate
	var elapsed_hours := floori(float(minutes_to_apply) / 60.0)
	offline_minutes_to_simulate = 0
	while minutes_to_apply > 0:
		var step := mini(60, minutes_to_apply)
		_advance_time(step)
		minutes_to_apply -= step
	_add_event("돌아오는 동안 " + str(elapsed_hours) + "시간이 흘렀어요. 이웃들의 하루도 이어졌어요.")
	_save_world()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_world()
