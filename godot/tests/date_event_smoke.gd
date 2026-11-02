extends SceneTree

const MAIN_SCRIPT := preload("res://scripts/main.gd")
const DATE_ART := preload("res://assets/date_evening_scene.png")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_path := "user://date_event_smoke_%d.cfg" % Time.get_ticks_usec()
	var game = MAIN_SCRIPT.new()
	game.save_path = save_path
	game.allow_external_services = false
	root.add_child(game)
	await process_frame
	assert(game.DATE_CHARACTER_MOMENTS.size() == 10)
	for resident in game.residents:
		assert(not game.DATE_CHARACTER_MOMENTS.get(resident.resident_id, {}).is_empty())

	var tired_neighbor: HaeondongResident = game._resident_by_id("yerin")
	tired_neighbor.player_affinity = 12
	game.relationships["yerin"] = 12
	tired_neighbor.energy = 20.0
	game._open_dialogue(tired_neighbor)
	game._dialogue_action("date_invite")
	assert(not game._has_appointment("yerin"))
	assert(game.dialogue_text.text.contains("기운이"))
	game._close_dialogue()


	var yun: HaeondongResident = game._resident_by_id("yun")
	yun.player_affinity = 11
	game.relationships["yun"] = 11
	game._open_dialogue(yun)
	assert(not game.date_invite_button.visible)
	yun.player_affinity = 12
	game.relationships["yun"] = 12
	game._update_date_invite_button(yun)
	assert(game.date_invite_button.visible and not game.date_invite_button.disabled)
	game.appointments.append({"resident_id": "yun", "day": game.day, "place": "공원", "resolved": false})
	game.game_minute = 16 * 60
	game.player.global_position = game.PLACES["카페"]
	game._update_hud()
	var money_before_warning: int = game.money
	var time_before_warning: int = game.game_minute
	game._perform_action("work")
	assert(game.money == money_before_warning)
	assert(game.game_minute == time_before_warning)
	assert(game.interaction_popup.visible)
	assert(game.late_warning_panel.visible)
	assert(game.story_panel.visible)
	assert(game.appointment_panel.visible)
	assert(game.events[0].contains("약속에 늦을 수 있어요"))
	game._process(4.6)
	await create_timer(0.45).timeout
	assert(not game.late_warning_panel.visible)
	game._process(8.1)
	await create_timer(0.7).timeout
	assert(not game.story_panel.visible)
	game._process(10.0)
	assert(game.game_minute == time_before_warning)
	game._on_interaction_choice_selected(1)
	await process_frame
	assert(game.money == money_before_warning)
	assert(game.game_minute == time_before_warning)
	assert(game.pending_activity_confirmation.is_empty())
	game.game_minute = 16 * 60 + 40
	game.current_interior = "카페"
	game._interact_with_object("커피 머신", "coffee")
	assert(game.interaction_popup.visible)
	assert(game.money == money_before_warning)
	assert(game.game_minute == 16 * 60 + 40)
	game._on_interaction_choice_selected(1)
	await process_frame
	assert(game.money == money_before_warning)
	assert(game.game_minute == 16 * 60 + 40)
	game.current_interior = ""
	var money_before_confirm: int = game.money
	game._perform_action("coffee")
	assert(game.interaction_popup.visible)
	assert(game.money == money_before_confirm)
	assert(game.events[0].contains("약속에 늦을 수 있어요"))
	game._on_interaction_choice_selected(0)
	await process_frame
	assert(game.money == money_before_confirm - 3)
	assert(game.game_minute == 17 * 60)
	assert(bool(game.appointments[0].get("resolved", false)))
	game.appointments.clear()
	game.game_minute = 8 * 60
	game.player.global_position = game.PLACES["골목"]
	yun.player_affinity = 12
	game.relationships["yun"] = 12
	var date_request: Dictionary = game._resolve_grounded_dialogue(yun, "우리 데이트할래?")
	assert(bool(date_request.get("handled", false)))
	assert(game.appointments.size() == 1)
	assert(bool(game.appointments[0].get("date_invitation", false)))
	assert(int(game.appointments[0].get("day", 0)) == game.day + 1)
	game._close_dialogue()

	game.day += 1
	game.game_minute = 17 * 60
	game.player.global_position = game.PLACES["공원"]
	yun.location = "공원"
	yun.visible = true
	var absolute_time: int = (game.day - 1) * game.DAY_MINUTES + game.game_minute
	game._resolve_appointments(absolute_time - 10, absolute_time)
	assert(game.active_date_event.get("resident_id", "") == "yun")
	assert(game.annual_event_panel.visible)
	assert(game.annual_event_art.texture == DATE_ART)
	assert(game.annual_event_cast_row.get_child_count() == 2)
	assert(game.annual_event_copy.text.contains("책") or game.annual_event_copy.text.contains("문장"))

	game._save_world()
	game.queue_free()
	await process_frame
	var resumed = MAIN_SCRIPT.new()
	resumed.save_path = save_path
	resumed.allow_external_services = false
	root.add_child(resumed)
	await process_frame
	assert(resumed.active_date_event.get("resident_id", "") == "yun")
	assert(resumed.annual_event_panel.visible)
	assert(resumed.annual_event_art.texture == DATE_ART)

	var affinity_before: int = resumed._resident_by_id("yun").player_affinity
	resumed._resolve_date_event("interest")
	assert(resumed.active_date_event.get("stage", "") == "result")
	assert(resumed.annual_event_panel.visible)
	assert(resumed._resident_by_id("yun").player_affinity == mini(100, affinity_before + 2))
	assert(resumed.date_records.size() == 1)
	assert(resumed.date_records[0].get("choice", "") == "interest")
	assert(resumed.annual_event_copy.text.contains("문장") or resumed.annual_event_copy.text.contains("책"))
	var date_memory_found := false
	for memory in resumed._resident_by_id("yun").memories:
		date_memory_found = date_memory_found or str(memory).contains("데이트")
	assert(date_memory_found)
	resumed._close_date_event_result()
	assert(resumed.active_date_event.is_empty())
	assert(not resumed.annual_event_panel.visible)
	resumed._save_world()

	resumed.queue_free()
	await process_frame
	var restored = MAIN_SCRIPT.new()
	restored.save_path = save_path
	restored.allow_external_services = false
	root.add_child(restored)
	await process_frame
	assert(restored.date_records.size() == 1)
	assert(restored._resident_by_id("yun").player_affinity == 14)
	assert(restored._can_invite_on_date(restored._resident_by_id("yun")) == false)
	print("Date event smoke checks: passed")
	restored.queue_free()
	await process_frame
	quit(0)
