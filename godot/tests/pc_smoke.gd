extends Node

const MAIN_SCRIPT := preload("res://scripts/main.gd")
const JEV_PROVIDER_SCRIPT := preload("res://scripts/jev_choice_provider.gd")
const OLLAMA_DIALOGUE_SCRIPT := preload("res://scripts/ollama_dialogue_provider.gd")


class DialogueProviderSpy:
	extends Node
	var request_count := 0

	func is_available() -> bool:
		return true

	func request_reply(_request_id: int, _player_text: String, _context: Dictionary) -> bool:
		request_count += 1
		return false


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures := 0
	var main_scene := load("res://scenes/main.tscn") as PackedScene
	var world_root := main_scene.instantiate() as Node2D
	failures += _check(absf(world_root.rotation) < 0.001 and world_root.position == Vector2.ZERO and world_root.scale.is_equal_approx(Vector2.ONE), "the world scene keeps neighborhood coordinates untransformed")
	world_root.free()
	var test_save_path := "user://pc_smoke_test_world.cfg"
	for suffix: String in ["", ".bak", ".tmp"]:
		var test_file := test_save_path + suffix
		if FileAccess.file_exists(test_file):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(test_file))
	var game := MAIN_SCRIPT.new()
	game.save_path = test_save_path
	game.allow_external_services = false
	add_child(game)
	await get_tree().process_frame
	var ollama_parser = OLLAMA_DIALOGUE_SCRIPT.new()
	var parsed_ollama_reply: Dictionary = ollama_parser.parse_chat_response(
		JSON.stringify({"done":true,"message":{"role":"assistant","content":"그 얘기 재미있네요."}})
	)
	var malformed_ollama_reply: Dictionary = ollama_parser.parse_chat_response("{broken json")
	var stage_direction_reply: Dictionary = ollama_parser.parse_chat_response(
		JSON.stringify({"done":true,"message":{"role":"assistant","content":"(웃으며) 반가워요. 오늘은 카페가 조금 한산하네요."}})
	)
	var english_reply: Dictionary = ollama_parser.parse_chat_response(
		JSON.stringify({"done":true,"message":{"role":"assistant","content":"I am happy to see you."}})
	)
	var installed_model_list: Dictionary = ollama_parser.parse_model_list(
		JSON.stringify({"models":[{"name":"gemma3:1b"}]})
	)
	var missing_model_list: Dictionary = ollama_parser.parse_model_list(
		JSON.stringify({"models":[{"name":"other-model"}]})
	)
	var safe_context := {
		"name":"예린",
		"role":"사서",
		"traits":"차분함",
		"values":"차분한 배려",
		"interests":"식물 기르기",
		"goal":"읽고 싶은 책 목록을 완성하기",
		"voice":"조용하고 간결한 존댓말",
		"memories":["플레이어가 도서관에서 조용히 책을 읽었다."],
		"location":"도서관",
		"relationship":"처음 만난 사이",
		"time_of_day":"낮"
	}
	var safe_instruction := ollama_parser.build_system_instruction(safe_context)
	var missing_memory_context := safe_context.duplicate(true)
	missing_memory_context["memories"] = []
	var missing_memory_instruction := ollama_parser.build_system_instruction(missing_memory_context)
	failures += _check(
		bool(parsed_ollama_reply.get("succeeded", false))
		and str(parsed_ollama_reply.get("reply", "")) == "그 얘기 재미있네요."
		and not bool(stage_direction_reply.get("succeeded", true))
		and not bool(english_reply.get("succeeded", true))
		and not bool(malformed_ollama_reply.get("succeeded", true)),
		"Ollama 응답은 한국어 대사만 정리해 읽고 지문·영어·잘못된 응답은 거절한다"
	)
	failures += _check(
		bool(installed_model_list.get("model_ready", false))
		and not bool(missing_model_list.get("model_ready", true))
		and safe_instruction.contains("예린")
		and safe_instruction.contains("한국어")
		and safe_instruction.contains("차분한 배려")
		and safe_instruction.contains("플레이어가 도서관에서 조용히 책을 읽었다.")
		and safe_instruction.contains("짧게 1~2문장")
		and missing_memory_instruction.contains("기억이 나지 않는다고 답하세요")
		and not safe_instruction.contains("private_worry"),
		"대화 문맥에 인물의 가치관과 저장 기억을 넣고 기억이 없을 때를 구분한다"
	)
	var yerin_for_context := game._resident_by_id("yerin")
	var original_energy := yerin_for_context.energy
	var original_social_need := yerin_for_context.social_need
	var original_memories: Array[String] = yerin_for_context.memories.duplicate()
	yerin_for_context.memories = [
		"플레이어가 도서관에서 조용히 책을 읽었다.",
		"플레이어에게 조심스러운 고민을 털어놓았다. " + yerin_for_context.private_worry
	]
	var private_memory_context: Dictionary = game._public_dialogue_context(yerin_for_context)
	var public_memory_context: Array = private_memory_context.get("memories", [])
	var private_memory_is_hidden := true
	for memory in public_memory_context:
		private_memory_is_hidden = private_memory_is_hidden and not str(memory).contains(yerin_for_context.private_worry)
	failures += _check(
		public_memory_context.size() == 1
		and str(public_memory_context[0]) == "플레이어가 도서관에서 조용히 책을 읽었다."
		and private_memory_is_hidden,
		"로컬 모델 문맥에는 저장된 공개 기억만 전달하고 아직 나누지 않은 고민은 제외한다"
	)
	yerin_for_context.energy = 10.0
	yerin_for_context.social_need = 90.0
	private_memory_context = game._public_dialogue_context(yerin_for_context)
	failures += _check(
		str(private_memory_context.get("mood", "")).contains("외롭고")
		and str(private_memory_context.get("energy", "")).contains("지쳐"),
		"대화 문맥에 주민의 현재 외로움과 피로가 반영된다"
	)
	yerin_for_context.memories = original_memories
	yerin_for_context.energy = original_energy
	yerin_for_context.social_need = original_social_need
	var local_chat_payload: Dictionary = ollama_parser.build_request_payload(
		"오늘은 어땠어?",
		{"recent_turns":[{"role":"user","text":"안녕"},{"role":"model","text":"반가워요."}]}
	)
	var local_chat_messages: Array = local_chat_payload.get("messages", [])
	var history_without_completed_pair := ollama_parser.build_request_payload(
		"오늘은 어땠어?",
		{"recent_turns":[{"role":"user","text":"전에 만난 일 기억해?"}]}
	)
	var history_without_pair_messages: Array = history_without_completed_pair.get("messages", [])
	failures += _check(
		str(local_chat_payload.get("model", "")) == "gemma3:1b"
		and str(local_chat_messages[2].get("role", "")) == "assistant"
		and history_without_pair_messages.size() == 2
		and not bool(local_chat_payload.get("stream", true)),
		"Ollama 요청은 로컬 모델과 완결된 대화 기록만 비스트리밍으로 전달한다"
	)
	ollama_parser.free()
	var jev_parser = JEV_PROVIDER_SCRIPT.new()
	var valid_jev_answer := {"answers": {"evening_scene": {"type": "choice", "choice": "pair_0", "confidence": 0.82}}}
	var parsed_jev_answer: Dictionary = jev_parser.parse_choice_response(JSON.stringify(valid_jev_answer), ["pair_0", "pair_1", "quiet_evening"])
	var invalid_jev_answer := {"answers": {"evening_scene": {"type": "choice", "choice": "unlisted_action", "confidence": 0.99}}}
	var rejected_jev_answer: Dictionary = jev_parser.parse_choice_response(JSON.stringify(invalid_jev_answer), ["pair_0", "pair_1", "quiet_evening"])
	failures += _check(bool(parsed_jev_answer.get("valid", false)) and str(parsed_jev_answer.get("choice_id", "")) == "pair_0" and not bool(rejected_jev_answer.get("valid", true)), "optional Jev decisions accept only listed choices and typed responses")
	jev_parser.free()
	var fallback_conversations: Array[Array] = []
	fallback_conversations.append([game._resident_by_id("yun"), game._resident_by_id("minjae")])
	fallback_conversations.append([game._resident_by_id("yerin"), game._resident_by_id("sua")])
	var ai_selected_conversations: Array[Array] = game._apply_jev_evening_choice("pair_1", 0.82, true, fallback_conversations)
	var low_confidence_fallback: Array[Array] = game._apply_jev_evening_choice("pair_0", 0.45, true, fallback_conversations)
	var ai_chose_quiet: Array[Array] = game._apply_jev_evening_choice("quiet_evening", 0.91, true, fallback_conversations)
	failures += _check(ai_selected_conversations.size() == 1 and ai_selected_conversations[0].has(game._resident_by_id("yerin")) and low_confidence_fallback.size() == 2 and ai_chose_quiet.is_empty(), "Jev can select a Korean-authored social scene while uncertain results use rules")
	var named_places_match_their_map_anchors := true
	for place_name in game.PLACES:
		named_places_match_their_map_anchors = named_places_match_their_map_anchors and game._location_of(game.PLACES[place_name]) == place_name
	var lower_shop_entrances_are_below_the_main_road := true
	for place_name in ["시장", "카페", "공방", "꽃집", "도서관"]:
		lower_shop_entrances_are_below_the_main_road = lower_shop_entrances_are_below_the_main_road and float(game.PLACES[place_name].y) >= 360.0 and float(game.PLACES[place_name].y) <= 410.0
	failures += _check(named_places_match_their_map_anchors and lower_shop_entrances_are_below_the_main_road, "place names and interaction anchors match the visible storefront row")
	failures += _check(game.residents.size() == 10, "PC build starts with all ten residents")
	failures += _check(game.INTERIOR_CATALOG.LAYOUTS.size() == 9 and game.INTERIOR_CATALOG.has_interior("카페") and game.INTERIOR_CATALOG.has_interior("도서관"), "each public building has a distinct indoor layout")
	failures += _check(game.get_node("HUD/Control").get_child_count() == 10, "PC HUD keeps world status and profile access without a fixed action bar")
	failures += _check(game.energy_meter != null and game.hunger_meter != null and game.energy_meter.max_value == 100.0 and game.hunger_meter.max_value == 100.0, "PC HUD shows bounded energy and hunger meters")
	failures += _check(game.energy_value_label.text == str(roundi(game.energy)) and game.hunger_value_label.text == str(roundi(game.hunger)) + "%", "PC HUD meter values match the player state")
	failures += _check(game.pause_panel.size == Vector2(332, 300) and game.journal_panel.size == Vector2(620, 390), "pause and profile panels use the refreshed layout")
	failures += _check(game.journal_button != null and game.pause_sound_button != null and game.controls_panel != null and game.help_panel != null and game.modal_scrim != null, "journal, pause, controls, help, and modal backdrop controls exist")
	var resident_collider := game._resident_by_id("taeo").get_node_or_null("BodyCollision") as CollisionShape2D
	var collision_setup_ready: bool = (
		game.player.get_node_or_null("BodyCollision") is CollisionShape2D
		and resident_collider != null
		and game._resident_by_id("taeo") is CharacterBody2D
		and game.world_collisions.get_child_count() >= 20
	)
	failures += _check(collision_setup_ready, "players, residents, and the neighborhood have physical collision shapes")
	var original_player_position: Vector2 = game.player.global_position
	var taeo_for_collision: HaeondongResident = game._resident_by_id("taeo")
	var original_taeo_position: Vector2 = taeo_for_collision.global_position
	var blocked_path: PackedVector2Array = game.world_collisions.route_for(Vector2(287, 260), Vector2(287, 365))
	var route_goes_around_the_building: bool = blocked_path.size() >= 2 and blocked_path[blocked_path.size() - 1] == Vector2(287, 365)
	failures += _check(route_goes_around_the_building, "resident routes go around solid storefront walls through the road network")
	game.player.global_position = Vector2(300, 230)
	taeo_for_collision.global_position = Vector2(315, 223)
	taeo_for_collision.target_position = taeo_for_collision.global_position
	await get_tree().physics_frame
	var residents_block_the_player := game.player.test_move(game.player.global_transform, Vector2(20, 0))
	game.player.global_position = Vector2(86, 220)
	await get_tree().physics_frame
	var building_blocks_the_player := game.player.test_move(game.player.global_transform, Vector2(0, -100))
	var resident_blocks_occupation: bool = taeo_for_collision.collision_layer == 2 and taeo_for_collision.collision_mask & game.player.collision_layer != 0
	game.player.global_position = original_player_position
	taeo_for_collision.global_position = original_taeo_position
	taeo_for_collision.target_position = original_taeo_position
	failures += _check(resident_blocks_occupation and building_blocks_the_player, "players cannot walk through residents or building walls")
	failures += _check(game.player.player_camera != null and game.player.player_camera.enabled and game.player.player_camera.zoom.x > 1.0 and game.player.player_camera.position_smoothing_enabled, "the camera follows the player with a closer view")
	if game.residents.size() != 10:
		get_tree().quit(1)
		return
	var natural_input_ready := (
		game.dialogue_input != null
		and game.dialogue_input.max_length == 240
		and game.dialogue_send_button != null
		and game.dialogue_choices_grid != null
	)
	failures += _check(natural_input_ready, "대화창에 글자 수가 제한된 자연어 입력과 전송 버튼이 있다")
	game._open_dialogue(game._resident_by_id("yun"))
	await get_tree().process_frame
	var dialogue_bottom := game.dialogue_panel.get_global_rect().end.y
	var choices_bottom := game.dialogue_choices_grid.get_global_rect().end.y
	failures += _check(
		game.dialogue_input.get_global_rect().position.y > game.dialogue_panel.get_global_rect().position.y
		and game.dialogue_status_label.get_global_rect().end.y < dialogue_bottom
		and choices_bottom < dialogue_bottom,
		"대사·자연어 입력·선택 버튼이 대화 패널 안에 배치된다"
	)
	game._close_dialogue()
	var resident_ids := {}
	var resident_positions := {}
	var resident_profiles_valid := true
	for resident in game.residents:
		resident_ids[resident.resident_id] = true
		resident_positions[str(resident.global_position)] = true
		resident_profiles_valid = resident_profiles_valid and resident.resident_id != "" and resident.resident_name != "" and resident.role != "" and resident.goal != "" and resident.traits.size() >= 2 and resident.values.size() >= 2 and resident.background != "" and resident.workplace in game.PLACES and resident.home in game.PLACES
	failures += _check(resident_ids.size() == 10 and resident_profiles_valid, "ten residents have distinct identities, roles, goals, homes, and workplaces")
	var goal_routines_valid := game.GOAL_ROUTINES.size() == game.residents.size()
	for resident in game.residents:
		var routine: Dictionary = game.GOAL_ROUTINES.get(resident.resident_id, {})
		goal_routines_valid = goal_routines_valid and str(routine.get("place", "")) in game.PLACES and not str(routine.get("memory", "")).is_empty()
	failures += _check(goal_routines_valid, "every resident has a valid place-bound autonomous goal routine")
	var goal_test_resident: HaeondongResident = game._resident_by_id("minjae")
	var goal_test_place: String = game.GOAL_ROUTINES[goal_test_resident.resident_id]["place"]
	goal_test_resident.location = goal_test_place
	goal_test_resident.visible = true
	goal_test_resident.energy = 80.0
	goal_test_resident.hunger = 30.0
	goal_test_resident.goal_progress = 27
	game.day = 4
	goal_test_resident.last_goal_step_day = 0
	var wrong_place_did_not_advance := not game._attempt_autonomous_goal_step(goal_test_resident, "공원")
	var relevant_routine_advanced := game._attempt_autonomous_goal_step(goal_test_resident, goal_test_place)
	var progress_after_first_step: int = goal_test_resident.goal_progress
	var repeated_same_day_was_blocked := not game._attempt_autonomous_goal_step(goal_test_resident, goal_test_place) and goal_test_resident.goal_progress == progress_after_first_step
	failures += _check(wrong_place_did_not_advance and relevant_routine_advanced and progress_after_first_step == 30 and repeated_same_day_was_blocked, "a resident advances a personal goal only through its relevant routine and once per day")
	failures += _check(game.events.any(func(event_text: String) -> bool: return event_text.contains("첫 단계")) and goal_test_resident.memories.any(func(memory: String) -> bool: return memory.contains("첫발")), "goal progress milestones leave a town event and personal memory")
	goal_test_resident.last_goal_step_day = game.day - 1
	goal_test_resident.energy = 24.0
	var tired_routine_was_skipped := not game._attempt_autonomous_goal_step(goal_test_resident, goal_test_place)
	goal_test_resident.energy = 80.0
	goal_test_resident.hunger = 90.0
	var hungry_routine_was_skipped := not game._attempt_autonomous_goal_step(goal_test_resident, goal_test_place)
	failures += _check(tired_routine_was_skipped and hungry_routine_was_skipped and goal_test_resident.goal_progress == progress_after_first_step, "poor energy or severe hunger can defer an autonomous goal routine")
	var memory_count_before_repeat: int = goal_test_resident.memories.size()
	game._add_memory(goal_test_resident, str(game.GOAL_ROUTINES[goal_test_resident.resident_id]["memory"]))
	game._add_memory(goal_test_resident, str(game.GOAL_ROUTINES[goal_test_resident.resident_id]["memory"]))
	var repeated_routine_memory_count := 0
	for memory in goal_test_resident.memories:
		if memory == str(game.GOAL_ROUTINES[goal_test_resident.resident_id]["memory"]):
			repeated_routine_memory_count += 1
	failures += _check(goal_test_resident.memories.size() == memory_count_before_repeat and repeated_routine_memory_count == 1, "repeated routine memories are compressed instead of displacing personal history")
	var portraits_valid := true
	for resident in game.residents:
		portraits_valid = portraits_valid and resident.sprite_texture != null and resident.sprite_size.x > 0 and resident.sprite_size.y > 0 and resident.portrait_texture != null and resident.portrait_texture.get_size().y >= 180
	failures += _check(portraits_valid, "all ten residents load a map sprite and a high-resolution dialogue portrait")
	var walk_frames_valid := game.player.walk_textures.size() == 4
	for resident in game.residents:
		walk_frames_valid = walk_frames_valid and resident.walk_textures.size() == 4
	failures += _check(walk_frames_valid, "the player and every resident load four separate walk frames")
	var animated_yun: HaeondongResident = game._resident_by_id("yun")
	animated_yun.target_position = animated_yun.position + Vector2(12, 0)
	animated_yun.walk_phase = TAU * 0.6
	animated_yun._animate_sprite(true)
	failures += _check(animated_yun.character_sprite.texture == animated_yun.walk_textures[2], "resident walking selects a frame from the walk cycle")
	animated_yun.target_position = animated_yun.position
	animated_yun._animate_sprite(false)
	var yun_for_daily_talk: HaeondongResident = game._resident_by_id("yun")
	var minjae_for_daily_talk: HaeondongResident = game._resident_by_id("minjae")
	game.game_minute = 8 * 60
	var morning_line := game._daily_small_talk(yun_for_daily_talk)
	game.game_minute = 13 * 60
	var afternoon_line := game._daily_small_talk(yun_for_daily_talk)
	failures += _check(morning_line != afternoon_line and morning_line != game._daily_small_talk(minjae_for_daily_talk), "daily small talk reflects the resident and time of day")
	game.game_minute = 6 * 60
	game._update_daily_schedule()
	failures += _check(game._resident_by_id("junho").target_location == "시장" and game._resident_by_id("minjae").target_location == "집", "residents keep distinct early-day routines")
	game.game_minute = 8 * 60
	game._update_daily_schedule()
	failures += _check(game._resident_by_id("minjae").target_location == "카페" and game._resident_by_id("daeun").target_location == "집", "neighbors leave home for work at different hours")
	game.game_minute = 22 * 60
	game._update_daily_schedule()
	var sleeping_residents_hidden := true
	for resident in game.residents:
		sleeping_residents_hidden = sleeping_residents_hidden and not resident.visible
	failures += _check(sleeping_residents_hidden and game._resident_near(game._resident_by_id("yun").global_position, 26.0) == null, "sleeping neighbors are indoors and cannot be accidentally approached")
	game.game_minute = 8 * 60
	game._update_daily_schedule()
	failures += _check(resident_positions.size() == 10, "residents who share a home have separate visible positions")
	failures += _check(game._resident_by_id("sua") != null and game._resident_by_id("dohyeon") != null and game._resident_by_id("gaeun") != null and game._resident_by_id("junho") != null and game._resident_by_id("daeun") != null and game._resident_by_id("taeo") != null and game._resident_by_id("somin") != null, "the seven additional residents can be looked up")
	var links_are_reciprocal := true
	for resident in game.residents:
		for other_id in resident.connections:
			var other := game._resident_by_id(str(other_id))
			links_are_reciprocal = links_are_reciprocal and other != null and other.connections.has(resident.resident_id)
	failures += _check(links_are_reciprocal and game._resident_by_id("sua").connections.has("junho"), "ten-resident starting relationships form a reciprocal town network")
	for resident in game.residents:
		resident.location = resident.home
		resident.social_need = 0.0
		resident.last_social_partner_id = ""
		resident.last_social_day = 0
	for resident_id in ["yun", "minjae", "yerin", "sua"]:
		var eligible_resident: HaeondongResident = game._resident_by_id(resident_id)
		eligible_resident.location = "공원"
		eligible_resident.social_need = 80.0
	var evening_pairs: Array = game._select_evening_pairs()
	var evening_pair_ids := {}
	var pairs_are_disjoint := evening_pairs.size() == 2
	for evening_pair in evening_pairs:
		for paired_resident in evening_pair:
			pairs_are_disjoint = pairs_are_disjoint and not evening_pair_ids.has(paired_resident.resident_id)
			evening_pair_ids[paired_resident.resident_id] = true
	failures += _check(evening_pairs.size() == 2 and pairs_are_disjoint and evening_pair_ids.size() == 4, "a busy evening can create two disjoint resident conversations")
	var recent_pair: Array = evening_pairs[0]
	var recent_first: HaeondongResident = recent_pair[0]
	var recent_second: HaeondongResident = recent_pair[1]
	recent_first.last_social_partner_id = recent_second.resident_id
	recent_second.last_social_partner_id = recent_first.resident_id
	recent_first.last_social_day = game.day - 1
	recent_second.last_social_day = game.day - 1
	var alternate_pairs: Array = game._select_evening_pairs()
	var repeated_recent_pair := false
	for alternate_pair in alternate_pairs:
		repeated_recent_pair = repeated_recent_pair or (alternate_pair.has(recent_first) and alternate_pair.has(recent_second))
	failures += _check(not repeated_recent_pair, "a resident pair is not scheduled again immediately after meeting")
	var yun_for_gossip: HaeondongResident = game._resident_by_id("yun")
	var yerin_for_gossip: HaeondongResident = game._resident_by_id("yerin")
	var minjae_for_gossip: HaeondongResident = game._resident_by_id("minjae")
	var taeo_for_gossip: HaeondongResident = game._resident_by_id("taeo")
	failures += _check(yerin_for_gossip.rumors.size() == 1 and float(yerin_for_gossip.rumors[0].get("confidence", 0.0)) == 0.85, "residents begin with only a small amount of second-hand town knowledge")
	var seed_rumor_source_id := str(yerin_for_gossip.rumors[0].get("event_id", ""))
	var seed_source_recorded := false
	for world_event in game.world_events:
		seed_source_recorded = seed_source_recorded or str(world_event.get("id", "")) == seed_rumor_source_id
	failures += _check(seed_source_recorded and minjae_for_gossip.known_events.has(seed_rumor_source_id) and not yun_for_gossip.known_events.has(seed_rumor_source_id) and not yerin_for_gossip.known_events.has(seed_rumor_source_id), "starting gossip separates the subject's knowledge from the source and listener")
	game._open_dialogue(yerin_for_gossip)
	failures += _check(game.dialogue_portrait.texture == yerin_for_gossip.portrait_texture and game.dialogue_name_label.text == yerin_for_gossip.resident_name and game.dialogue_mood_label.text == "편안", "conversation opens with the speaking resident's portrait and name")
	game._dialogue_action("news")
	failures += _check(game.dialogue_text.text.contains("민재") and game.dialogue_text.text.contains("윤에게") and game.dialogue_mood_label.text == "궁금", "asking about town news reveals its source and changes portrait mood")
	game._close_dialogue()
	var confidence_before_spread := float(yerin_for_gossip.rumors[0].get("confidence", 0.0))
	failures += _check(game._spread_rumor(yerin_for_gossip, taeo_for_gossip), "a known non-secret rumor can pass through a resident conversation")
	var passed_rumor: Dictionary = taeo_for_gossip.rumors[0] if not taeo_for_gossip.rumors.is_empty() else {}
	failures += _check(float(passed_rumor.get("confidence", 1.0)) < confidence_before_spread and str(passed_rumor.get("heard_from", "")) == "yerin", "retold rumors lose confidence and remember who retold them")
	failures += _check(not str(passed_rumor.get("text", "")).contains(yerin_for_gossip.private_worry), "private worries are excluded from rumor sharing")
	minjae_for_gossip.rumors.clear()
	game._record_world_event("예린이 도서관에서 함께 읽을 책을 골랐어요.", "npc_goal", [yerin_for_gossip.resident_id], false)
	for resident in game.residents:
		resident.location = resident.home
		resident.social_need = 0.0
	minjae_for_gossip.location = "공원"
	yerin_for_gossip.location = "공원"
	minjae_for_gossip.social_need = 60.0
	yerin_for_gossip.social_need = 60.0
	minjae_for_gossip.last_social_partner_id = ""
	yerin_for_gossip.last_social_partner_id = ""
	game.day = 3
	game._run_evening_society()
	failures += _check(not minjae_for_gossip.rumors.is_empty(), "the evening society simulation can pass local news without player input")
	game._open_dialogue(yun_for_gossip)
	failures += _check(not game.confide_button.visible, "private concerns remain unavailable to a new acquaintance")
	game._dialogue_action("confide")
	failures += _check(not yun_for_gossip.secret_shared_with_player, "a direct request cannot bypass the relationship threshold")
	yun_for_gossip.player_affinity = 6
	game._open_dialogue(yun_for_gossip)
	failures += _check(game.confide_button.visible, "a close relationship unlocks a private conversation")
	game._dialogue_action("confide")
	var secret_leaked_to_events := false
	for event_text in game.events:
		secret_leaked_to_events = secret_leaked_to_events or event_text.contains(yun_for_gossip.private_worry)
	failures += _check(yun_for_gossip.secret_shared_with_player and game.dialogue_text.text.contains(yun_for_gossip.private_worry) and not secret_leaked_to_events, "a private concern is shared with the player but excluded from town history")
	game._close_dialogue()
	game.day = 1
	minjae_for_gossip.player_affinity = 2
	minjae_for_gossip.energy = 82.0
	minjae_for_gossip.social_need = 60.0
	game._open_dialogue(minjae_for_gossip)
	game._dialogue_action("invite")
	failures += _check(game._has_appointment("minjae") and game.dialogue_text.text.contains("내일 오후 다섯 시"), "an available neighbor can accept a next-day invitation")
	game._close_dialogue()
	yun_for_gossip.player_affinity = 2
	yun_for_gossip.energy = 82.0
	yun_for_gossip.social_need = 40.0
	game._open_dialogue(yun_for_gossip)
	game._dialogue_action("invite")
	failures += _check(not game._has_appointment("yun") and game.dialogue_text.text.contains("약속을 잡지 않는"), "a busy neighbor can politely decline without losing affinity")
	game._close_dialogue()
	var yerin_for_invite: HaeondongResident = game._resident_by_id("yerin")
	yerin_for_invite.player_affinity = 2
	yerin_for_invite.energy = 10.0
	game._open_dialogue(yerin_for_invite)
	game._dialogue_action("invite")
	failures += _check(not game._has_appointment("yerin") and yerin_for_invite.energy < 25.0, "an exhausted neighbor does not accept a social plan")
	game._close_dialogue()
	game.appointments.clear()
	game._open_dialogue(yerin_for_gossip)
	var original_dialogue_provider = game.ollama_dialogue_provider
	var dialogue_provider_spy := DialogueProviderSpy.new()
	game.add_child(dialogue_provider_spy)
	game.ollama_dialogue_provider = dialogue_provider_spy
	game.appointments.append({
		"resident_id": yerin_for_gossip.resident_id,
		"day": game.day + 1,
		"place": "공원",
		"resolved": false
	})
	game.dialogue_input.text = "내일 공원에서 만나기로 한 약속 기억나요?"
	game._on_dialogue_send_pressed()
	failures += _check(
		game.dialogue_text.text.contains("내일 공원에서 만나기로 했어요")
		and game._has_appointment(yerin_for_gossip.resident_id),
		"약속 확인 대사는 Ollama를 건너뛰고 확정된 약속 상태를 직접 조회한다"
	)
	game.appointments.clear()
	var saved_yerin_invitation_state := {
		"energy": yerin_for_gossip.energy,
		"social_need": yerin_for_gossip.social_need,
		"player_affinity": yerin_for_gossip.player_affinity
	}
	yerin_for_gossip.energy = 85.0
	yerin_for_gossip.social_need = 65.0
	yerin_for_gossip.player_affinity = 5
	var natural_invitation: Dictionary = game._resolve_grounded_dialogue(
		yerin_for_gossip,
		"이번 주말 같이 산책할래?"
	)
	failures += _check(
		bool(natural_invitation.get("handled", false))
		and game._has_appointment(yerin_for_gossip.resident_id)
		and str(natural_invitation.get("reply", "")).contains("공원에서 만나요"),
		"자유 입력 초대도 모델이 아니라 약속 규칙에 따라 일정을 등록한다"
	)
	game.appointments.clear()
	yerin_for_gossip.energy = float(saved_yerin_invitation_state["energy"])
	yerin_for_gossip.social_need = float(saved_yerin_invitation_state["social_need"])
	yerin_for_gossip.player_affinity = int(saved_yerin_invitation_state["player_affinity"])
	yerin_for_gossip.last_contact_day = 0
	game._dialogue_action("ask")
	failures += _check(game.dialogue_text.text.contains(yerin_for_gossip.background), "personal conversations reveal a resident's background")
	game._dialogue_action("hobby")
	failures += _check(game.dialogue_text.text.contains(yerin_for_gossip.preferences[0]) and game.dialogue_text.text.contains(yerin_for_gossip.values[0]), "hobby conversations reveal individual preferences and values")
	var saved_yerin_memories: Array[String] = yerin_for_gossip.memories.duplicate()
	yerin_for_gossip.memories = ["플레이어가 도서관에서 조용히 책을 읽었다."]
	game.dialogue_input.text = "지난번에 내가 도서관에서 읽었던 책 기억나요?"
	game._on_dialogue_send_pressed()
	var known_memory_reply := game.dialogue_text.text
	game.dialogue_input.text = "지난주에 내가 너한테 빌려준 시집 기억나? 아직 갖고 있어?"
	game._on_dialogue_send_pressed()
	var missing_memory_reply := game.dialogue_text.text
	var ordinary_past_chat: Dictionary = game._resolve_grounded_dialogue(
		yerin_for_gossip,
		"어제 비가 와서 산책하기 좋았어"
	)
	failures += _check(
		known_memory_reply.contains("당신이 도서관에서 조용히 책을 읽었다고 기억하고 있어요")
		and missing_memory_reply.contains("정확히 기억나지 않아요")
		and not missing_memory_reply.contains("네, 당신이")
		and not bool(ordinary_past_chat.get("handled", false))
		and dialogue_provider_spy.request_count == 0,
		"기억 질문은 Ollama를 건너뛰고 일치하는 저장 기억만 답하며 없는 기억을 인정하지 않는다"
	)
	yerin_for_gossip.memories = saved_yerin_memories
	game.dialogue_input.text = "오늘 길에서 작은 새를 봤어"
	game._on_dialogue_send_pressed()
	failures += _check(
		dialogue_provider_spy.request_count == 1,
		"저장 사실이 필요 없는 자유 대화는 로컬 모델로 이어진다"
	)
	game.ollama_dialogue_provider = original_dialogue_provider
	dialogue_provider_spy.queue_free()
	game.dialogue_input.text = "오늘 길에서 고양이를 봤어"
	game._on_dialogue_send_pressed()
	var first_natural_affinity := yerin_for_gossip.player_affinity
	failures += _check(
		game.dialogue_text.text.contains(yerin_for_gossip.preferences[0])
		and game.dialogue_input.text.is_empty()
		and game.dialogue_input.editable,
		"자유 입력은 주민의 관심사에 맞는 기본 대화로 이어진다"
	)
	game.dialogue_input.text = "오늘은 어땠어?"
	game._on_dialogue_send_pressed()
	failures += _check(
		yerin_for_gossip.player_affinity == first_natural_affinity,
		"같은 날 자유 대화를 반복해도 관계 수치가 계속 오르지 않는다"
	)
	game._close_dialogue()
	var event_witness: HaeondongResident = game._resident_by_id("sua")
	var rumor_listener: HaeondongResident = game._resident_by_id("taeo")
	event_witness.rumors.clear()
	rumor_listener.rumors.clear()
	var witnessed_event_id := game._record_world_event("수아가 꽃집에서 계절 전시를 준비했어요.", "npc_goal", [event_witness.resident_id], false)
	var event_became_rumor := game._spread_rumor(event_witness, rumor_listener)
	var transmitted_rumor: Dictionary = rumor_listener.rumors[0] if not rumor_listener.rumors.is_empty() else {}
	failures += _check(event_witness.known_events.has(witnessed_event_id) and not rumor_listener.known_events.has(witnessed_event_id) and str(transmitted_rumor.get("event_id", "")) == witnessed_event_id and float(transmitted_rumor.get("confidence", 1.0)) < 1.0, "a witnessed event reaches another resident only as a lower-confidence rumor")
	var secret_speaker: HaeondongResident = game._resident_by_id("gaeun")
	var secret_listener: HaeondongResident = game._resident_by_id("junho")
	secret_speaker.rumors.clear()
	secret_listener.rumors.clear()
	game._record_world_event("가은이 혼자 간직하고 싶은 고민을 나눴어요.", "secret", [secret_speaker.resident_id], false)
	failures += _check(not game._spread_rumor(secret_speaker, secret_listener), "a private event cannot be selected for rumor transmission")
	var conflict_first: HaeondongResident = game._resident_by_id("sua")
	var conflict_second: HaeondongResident = game._resident_by_id("dohyeon")
	game.day = 8
	var relation_before_misunderstanding: int = int(conflict_first.connections.get(conflict_second.resident_id, 0))
	var misunderstanding_created := game._create_misunderstanding(conflict_first, conflict_second, witnessed_event_id)
	var created_tension := game._active_tension_between(conflict_first, conflict_second)
	failures += _check(misunderstanding_created and not created_tension.is_empty() and int(conflict_first.connections.get(conflict_second.resident_id, 0)) == relation_before_misunderstanding - 1, "uncertain news can create a remembered misunderstanding and strain the relationship")
	failures += _check(not game._create_misunderstanding(conflict_first, conflict_second, witnessed_event_id), "an active misunderstanding cannot duplicate itself")
	conflict_first.player_affinity = 2
	game._open_dialogue(conflict_first)
	failures += _check(game.mediate_button.visible, "a trusted player can choose to mediate an active misunderstanding")
	game._dialogue_action("news")
	failures += _check(game.dialogue_text.text.contains(conflict_second.resident_name), "a resident can talk about the neighbor involved in a misunderstanding")
	game._dialogue_action("mediate")
	failures += _check(bool(created_tension.get("mediated", false)) and not game.mediate_button.visible, "player mediation records a request to talk things through")
	game._close_dialogue()
	game.day = 9
	game.last_society_day = 0
	for resident in game.residents:
		resident.location = resident.home
		resident.social_need = 0.0
		resident.visible = true
		resident.last_social_partner_id = ""
		resident.last_social_day = 0
	conflict_first.location = "공원"
	conflict_second.location = "공원"
	conflict_first.social_need = 60.0
	conflict_second.social_need = 60.0
	conflict_first.last_social_partner_id = ""
	conflict_second.last_social_partner_id = ""
	game.player.global_position = game.PLACES["공원"]
	game._run_evening_society()
	failures += _check(str(created_tension.get("status", "")) == "resolved" and int(conflict_first.connections.get(conflict_second.resident_id, 0)) == relation_before_misunderstanding + 1, "mediated neighbors can reconcile when they meet and rebuild trust")
	var reconciliation_recorded := false
	for world_event in game.world_events:
		if str(world_event.get("kind", "")) == "reconciliation" and world_event.get("known_by", []).has(conflict_first.resident_id) and world_event.get("known_by", []).has(conflict_second.resident_id):
			reconciliation_recorded = true
	failures += _check(reconciliation_recorded, "a reconciliation leaves a witnessed social event in the world ledger")
	var paused_minute: int = game.game_minute
	game._open_journal()
	game._process(1.0)
	failures += _check(game.game_minute == paused_minute, "opening the journal pauses the world clock")
	failures += _check(game.modal_scrim.visible, "journal dims and blocks the world behind it")
	game._close_journal()
	game._open_pause()
	game._process(1.0)
	failures += _check(game.game_minute == paused_minute, "opening the pause menu pauses the world clock")
	failures += _check(game.modal_scrim.visible, "pause menu dims the neighborhood")
	game._close_pause()
	var inventory_key := InputEventKey.new()
	inventory_key.pressed = true
	inventory_key.keycode = KEY_I
	game._unhandled_input(inventory_key)
	failures += _check(game.journal_panel.visible and game.journal_view == "inventory" and game.profile_title.text == "가방", "I key opens the inventory view")
	var item_art_is_complete := MAIN_SCRIPT.ITEM_CATALOG.size() == game.inventory.size()
	for item_data in MAIN_SCRIPT.ITEM_CATALOG:
		var icon := load("res://assets/items/" + str(item_data["id"]) + ".svg") as Texture2D
		item_art_is_complete = item_art_is_complete and icon != null and icon.get_width() >= 48 and icon.get_height() >= 48
	item_art_is_complete = item_art_is_complete and game.inventory_grid.get_child_count() == MAIN_SCRIPT.ITEM_CATALOG.size()
	item_art_is_complete = item_art_is_complete and load("res://assets/items/bag.svg") is Texture2D
	failures += _check(item_art_is_complete, "all carried and seasonal items have individual pixel-art icons in the bag")
	var player_info_key := InputEventKey.new()
	player_info_key.pressed = true
	player_info_key.keycode = KEY_C
	game._unhandled_input(player_info_key)
	failures += _check(game.journal_view == "player" and game.journal_text.text.contains("지갑"), "C key switches to player information")
	var residents_key := InputEventKey.new()
	residents_key.pressed = true
	residents_key.keycode = KEY_N
	game._unhandled_input(residents_key)
	failures += _check(game.journal_view == "residents" and game.profile_title.text == "주민 도감", "N key switches to the resident collection")
	var escape_key := InputEventKey.new()
	escape_key.pressed = true
	escape_key.keycode = KEY_ESCAPE
	game._unhandled_input(escape_key)
	failures += _check(not game.journal_panel.visible, "Escape closes the profile panel")
	game._unhandled_input(escape_key)
	failures += _check(game.pause_panel.visible, "Escape opens the pause menu")
	var help_key := InputEventKey.new()
	help_key.pressed = true
	help_key.keycode = KEY_F1
	game._unhandled_input(help_key)
	failures += _check(game.help_panel.visible, "F1 opens help from the pause menu")
	game._close_help()
	failures += _check(game.pause_panel.visible, "closing help returns to the pause menu")
	game._close_pause()
	game._unhandled_input(help_key)
	game._process(1.0)
	failures += _check(game.help_panel.visible and game.game_minute == paused_minute, "F1 opens a time-pausing help panel")
	game._unhandled_input(escape_key)
	failures += _check(not game.help_panel.visible, "Escape closes help")
	game._open_pause()
	game._open_controls_settings()
	var settings_minute: int = game.game_minute
	game._process(1.0)
	failures += _check(game.controls_panel.visible and not game.pause_panel.visible and game.game_minute == settings_minute, "control settings pause the world and open above the pause menu")
	game._begin_control_rebind("inventory")
	var remap_key := InputEventKey.new()
	remap_key.pressed = true
	remap_key.keycode = KEY_K
	game._unhandled_input(remap_key)
	failures += _check(game.controls_settings.label_for("inventory") == "K", "a shortcut can be rebound from the controls panel")
	failures += _check(not game.controls_settings.rebind("calendar", KEY_K).is_empty(), "shortcut conflicts are explained and rejected")
	game.ui_scale_slider.value = 1.2
	game.reduce_motion_button.toggled.emit(true)
	failures += _check(is_equal_approx(game.ui_text_scale, 1.2) and game.ui_scale_value_label.text == "120%", "UI text size can be enlarged and is reported clearly")
	failures += _check(game.reduce_motion and game.player.reduce_motion and game.residents.all(func(resident: HaeondongResident) -> bool: return resident.reduce_motion), "reduced motion is applied to the player and every resident")
	animated_yun._animate_sprite(false)
	failures += _check(animated_yun.character_sprite.texture == animated_yun.sprite_texture, "reduced motion keeps walking sprites on a still frame")
	game._close_controls_settings()
	game._close_pause()
	var remapped_inventory_key := InputEventKey.new()
	remapped_inventory_key.pressed = true
	remapped_inventory_key.keycode = KEY_K
	game._unhandled_input(remapped_inventory_key)
	failures += _check(game.journal_panel.visible and game.journal_view == "inventory", "the new shortcut opens its assigned screen")
	game._close_journal()
	game.player.global_position = game.PLACES["카페"] + Vector2(0, -38)
	game._interact_nearby()
	var overlapping_choices_are_available := game.interaction_popup.get_item_count() >= 2
	game._on_interaction_choice_selected(0)
	await get_tree().process_frame
	failures += _check(game.current_interior == "카페" and not game._resident_by_id("minjae").visible, "E at the cafe entrance opens its interior")
	failures += _check(overlapping_choices_are_available, "overlapping doors, residents, and places offer a target selection menu")
	game.current_interior = "집"
	game.player.global_position = Vector2(465, 190)
	game._interact_interior()
	failures += _check(game.events[0].contains("화분"), "small interior props have their own contextual interaction")
	game.current_interior = "카페"
	game.player.global_position = Vector2(480, 420)
	game._interact_interior()
	failures += _check(game.current_interior.is_empty() and game.player.global_position.distance_to(game.PLACES["카페"]) < 70.0, "the cafe interior door returns to the same outdoor building")

	var minjae: HaeondongResident = game._resident_by_id("minjae")
	game.player.global_position = game.PLACES["카페"]
	minjae.location = "카페"
	minjae.visible = true
	var distant_observer: HaeondongResident = game._resident_by_id("taeo")
	distant_observer.location = "학교"
	distant_observer.visible = true
	var money_before: int = game.money
	var minute_before: int = game.game_minute
	game._perform_action("work")
	var observed_work_event: Dictionary = game.world_events[game.world_events.size() - 1] if not game.world_events.is_empty() else {}
	var observed_work_event_id: String = str(observed_work_event.get("id", ""))
	failures += _check(game.money == money_before + 12, "working at the cafe pays the player")
	failures += _check(game.game_minute == minute_before + 120, "work advances two in-game hours")
	failures += _check(observed_work_event_id.begins_with("town_") and minjae.known_events.has(observed_work_event_id) and not distant_observer.known_events.has(observed_work_event_id), "only a resident at the player's location remembers a witnessed action")
	game.player.global_position = game.PLACES["서점"]
	var book_price := 2 if game._resident_by_id("yun").milestone_reached else 5
	game._perform_action("local")
	failures += _check(game.inventory["책"] >= 1, "visiting the bookstore adds a book to the bag")
	failures += _check(game.money == money_before + 12 - book_price, "book purchase charges the correct price")

	var yun: HaeondongResident = game._resident_by_id("yun")
	game._open_dialogue(yun)
	var affinity_before: int = yun.player_affinity
	var goal_before: int = yun.goal_progress
	game._dialogue_action("gift_book")
	failures += _check(game.inventory["책"] == 0, "gift consumes inventory")
	failures += _check(yun.player_affinity > affinity_before, "gift changes the relationship")
	failures += _check(yun.memories[0].contains("선물"), "gift becomes a resident memory")
	if not yun.milestone_reached:
		failures += _check(yun.goal_progress == goal_before + 6, "gift helps a resident make progress toward a goal")

	game.day = 2
	game.game_minute = 20 * 60
	game.last_society_day = 0
	yun.location = "공원"
	minjae.location = "공원"
	yun.social_need = 60.0
	minjae.social_need = 60.0
	var connection_before: int = int(yun.connections.get("minjae", 0))
	game._run_evening_society()
	failures += _check(yun.memories[0].contains("민재") and minjae.memories[0].contains("윤"), "residents remember a private conversation without player input")
	failures += _check(int(yun.connections.get("minjae", 0)) == connection_before + 1, "resident-to-resident conversation changes their relationship")
	var first_evening_day: int = game.day
	for evening in range(50):
		game.day = first_evening_day + evening + 1
		for resident in game.residents:
			resident.energy = 80.0
			resident.hunger = 30.0
			resident.visible = true
			resident.location = str(game.GOAL_ROUTINES[resident.resident_id]["place"])
			resident.last_goal_step_day = game.day - 1
			game._attempt_autonomous_goal_step(resident, resident.location)
		game._run_evening_society()
	var all_goals_completed := true
	for resident in game.residents:
		all_goals_completed = all_goals_completed and resident.milestone_reached and resident.goal_progress == 100
		all_goals_completed = all_goals_completed and resident.memories.size() <= 20
	failures += _check(all_goals_completed, "residents can complete distinct long-term goals through accumulated days")
	failures += _check(game.events.size() <= 12, "long-running town history remains bounded")

	var target_day: int = game.day + 7
	while game.day < target_day:
		game._advance_time(120)
	failures += _check(game.day == target_day, "simulation advances through a full week")
	failures += _check(not game.events.is_empty(), "week produces a town history")
	failures += _check(minjae.money > 0 and minjae.hunger <= 100.0, "resident needs and earnings stay bounded")
	game._toggle_sound()
	failures += _check(not game.sound_enabled and game.sound_button.text == "효과음: 끔", "sound setting can be switched off")
	var places_valid := true
	for resident in game.residents:
		places_valid = places_valid and resident.location in game.PLACES
	failures += _check(places_valid, "residents retain valid places")

	game._save_world()
	var saved_money: int = game.money
	var saved_affinity: int = yun.player_affinity
	var saved_goal_step_day: int = yun.last_goal_step_day
	var saved_social_partner_id: String = yun.last_social_partner_id
	var saved_reconciliation_id: String = str(created_tension.get("id", ""))
	var save_uri: String = game.save_path
	game.queue_free()
	await get_tree().process_frame
	var restored := MAIN_SCRIPT.new()
	restored.save_path = test_save_path
	restored.allow_external_services = false
	add_child(restored)
	await get_tree().process_frame
	var restored_yun: HaeondongResident = restored._resident_by_id("yun")
	failures += _check(restored.residents.size() == 10 and restored._resident_by_id("somin") != null, "all ten residents survive save and load")
	var restored_minjae: HaeondongResident = restored._resident_by_id("minjae")
	var restored_yerin: HaeondongResident = restored._resident_by_id("yerin")
	var saved_goal_rumor := false
	for rumor in restored_yerin.rumors:
		saved_goal_rumor = saved_goal_rumor or str(rumor.get("event_id", "")) == "goal_minjae"
	failures += _check(restored_yun.secret_shared_with_player and saved_goal_rumor, "private sharing and local rumor knowledge survive save and load")
	failures += _check(restored.money == saved_money, "player money survives save and load")
	failures += _check(restored_yun.player_affinity == saved_affinity, "resident relationship survives save and load")
	failures += _check(restored_yun.last_goal_step_day == saved_goal_step_day, "autonomous goal routine cooldown survives save and load")
	failures += _check(restored_yun.last_social_partner_id == saved_social_partner_id, "recent social partner survives save and load")
	var restored_witness_event := false
	for world_event in restored.world_events:
		restored_witness_event = restored_witness_event or str(world_event.get("id", "")) == observed_work_event_id
	var restored_witness: HaeondongResident = restored._resident_by_id("minjae")
	failures += _check(restored_witness_event and restored_witness.known_events.has(observed_work_event_id), "world event ledger and resident witness knowledge survive save and load")
	var restored_seed_rumor_source := false
	for world_event in restored.world_events:
		restored_seed_rumor_source = restored_seed_rumor_source or str(world_event.get("id", "")) == seed_rumor_source_id
	failures += _check(
		restored_seed_rumor_source
		and restored_minjae.known_events.has(seed_rumor_source_id)
		and not restored_yun.known_events.has(seed_rumor_source_id)
		and not restored_yerin.known_events.has(seed_rumor_source_id),
		"original rumor knowledge stays asymmetric after save and load"
	)
	var restored_reconciliation := false
	for tension in restored.tensions:
		restored_reconciliation = restored_reconciliation or (str(tension.get("id", "")) == saved_reconciliation_id and str(tension.get("status", "")) == "resolved")
	failures += _check(restored_reconciliation, "resolved social tensions survive save and load")
	failures += _check(restored.inventory["책"] == 0, "inventory survives save and load")
	failures += _check(not restored.sound_enabled, "sound preference survives save and load")
	failures += _check(restored.controls_settings.label_for("inventory") == "K", "custom keyboard settings survive save and load")
	failures += _check(is_equal_approx(restored.ui_text_scale, 1.2) and restored.reduce_motion, "accessibility settings survive save and load")
	failures += _check(_has_memory(restored_yun.memories, "선물"), "resident memory survives save and load")
	var recovered_money: int = restored.money
	var recovered_affinity: int = restored_yun.player_affinity
	var recovered_memory: String = restored_yun.memories[0]
	restored._save_world()
	var corrupt_save := FileAccess.open(save_uri, FileAccess.WRITE)
	corrupt_save.store_string("invalid save data")
	corrupt_save.close()
	restored.queue_free()
	await get_tree().process_frame
	var recovered := MAIN_SCRIPT.new()
	recovered.save_path = test_save_path
	recovered.allow_external_services = false
	add_child(recovered)
	await get_tree().process_frame
	var recovered_yun: HaeondongResident = recovered._resident_by_id("yun")
	failures += _check(recovered.money == recovered_money, "corrupt primary save restores money from the valid backup")
	failures += _check(recovered_yun.player_affinity == recovered_affinity, "corrupt primary save restores relationships from the backup")
	failures += _check(not recovered_yun.memories.is_empty() and recovered_yun.memories[0] == recovered_memory, "corrupt primary save restores resident memories from the backup")
	failures += _check(FileAccess.get_file_as_string(save_uri).begins_with("["), "corrupt primary save is replaced with the valid backup")
	print("PC smoke checks: %d failures" % failures)
	get_tree().quit(1 if failures > 0 else 0)


func _check(condition: bool, description: String) -> int:
	if condition:
		print("PASS: " + description)
		return 0
	push_error("FAIL: " + description)
	return 1


func _has_memory(memories: Array[String], fragment: String) -> bool:
	for memory in memories:
		if memory.contains(fragment):
			return true
	return false
