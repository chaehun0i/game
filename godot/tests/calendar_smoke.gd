extends SceneTree

const MAIN_SCRIPT := preload("res://scripts/main.gd")
const CALENDAR_SCRIPT := preload("res://scripts/calendar_system.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(CALENDAR_SCRIPT.date_for_day(1)["season"] == "봄")
	assert(CALENDAR_SCRIPT.date_for_day(29)["season"] == "여름")
	assert(CALENDAR_SCRIPT.date_for_day(113)["year"] == 2)
	assert(CALENDAR_SCRIPT.event_for_day(14)["kind"] == "seasonal")
	assert(CALENDAR_SCRIPT.event_for_day(112)["kind"] == "year_end")

	var game = MAIN_SCRIPT.new()
	game.save_path = "user://calendar_smoke_world_" + str(Time.get_ticks_usec()) + ".cfg"
	game.allow_external_services = false
	root.add_child(game)
	await process_frame
	assert(game.residents.size() == 10)
	assert(game.player.character_sprite.texture != null)
	assert(game._resident_by_id("sua").portrait_texture != null)
	game.player.set_appearance("해온", 3)
	game.player_display_name = "해온"
	game.player_outfit_style = 3
	assert(game.player.display_name == "해온")
	assert(game.player.outfit_style == 3)

	for resident in game.residents:
		resident.player_affinity = 0
		resident.memories.clear()
	game._resident_by_id("somin").player_affinity = 12
	game._resident_by_id("sua").connections["somin"] = 100
	game._resident_by_id("somin").connections["sua"] = 100
	var spring := CALENDAR_SCRIPT.event_for_day(14)
	var cast: Array[String] = game._select_calendar_attendees(spring)
	assert(cast.size() <= 3 and not cast.is_empty())
	assert(cast[0] == "somin")
	assert(cast.has("sua"))

	game.day = 14
	game.game_minute = 18 * 60
	game._check_calendar_event()
	assert(game.annual_event_panel.visible)
	assert(game.annual_event_cast_row.get_child_count() == game.annual_event_cast.size())
	game._resolve_annual_event("rest")
	assert(not game.annual_event_panel.visible)
	assert(game.annual_records.size() == 1)
	assert(game.annual_records[0]["choice"] == "rest")
	game.day = 112
	game.game_minute = 18 * 60
	game._check_calendar_event()
	assert(game.active_annual_event["kind"] == "year_end")
	assert(game.annual_event_cast.size() <= 4)
	game._resolve_annual_event("rest")
	assert(CALENDAR_SCRIPT.date_for_day(113)["year"] == 2)
	game._save_world()
	var restored = MAIN_SCRIPT.new()
	restored.save_path = game.save_path
	restored.allow_external_services = false
	root.add_child(restored)
	await process_frame
	assert(restored.player_display_name == "해온")
	assert(restored.player_outfit_style == 3)
	assert(restored.annual_records.size() == 2)
	print("달력·관계 기반 행사 참석자·플레이어 꾸미기 확인 완료")
	restored.queue_free()
	game.queue_free()
	await process_frame
	quit(0)
