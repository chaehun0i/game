extends Node

const MAIN_SCRIPT := preload("res://scripts/main.gd")


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures := 0
	var test_save_path := "user://pc_smoke_test_world.cfg"
	for suffix: String in ["", ".bak", ".tmp"]:
		var test_file := test_save_path + suffix
		if FileAccess.file_exists(test_file):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(test_file))
	var game := MAIN_SCRIPT.new()
	game.save_path = test_save_path
	add_child(game)
	await get_tree().process_frame
	failures += _check(game.residents.size() == 10, "PC build starts with all ten residents")
	failures += _check(game.action_buttons.size() == 6, "PC HUD exposes six activity buttons")
	failures += _check(game.journal_button != null and game.pause_sound_button != null and game.help_panel != null and game.modal_scrim != null, "journal, pause, help, and modal backdrop controls exist")
	if game.residents.size() != 10:
		get_tree().quit(1)
		return
	var resident_ids := {}
	var resident_positions := {}
	var resident_profiles_valid := true
	for resident in game.residents:
		resident_ids[resident.resident_id] = true
		resident_positions[str(resident.global_position)] = true
		resident_profiles_valid = resident_profiles_valid and resident.resident_id != "" and resident.resident_name != "" and resident.role != "" and resident.goal != "" and resident.workplace in game.PLACES and resident.home in game.PLACES
	failures += _check(resident_ids.size() == 10 and resident_profiles_valid, "ten residents have distinct identities, roles, goals, homes, and workplaces")
	var portraits_valid := true
	for resident in game.residents:
		portraits_valid = portraits_valid and resident.sprite_texture != null and resident.sprite_size.x > 0 and resident.sprite_size.y > 0
	failures += _check(portraits_valid, "all ten residents load an individually cropped portrait")
	failures += _check(resident_positions.size() == 10, "residents who share a home have separate visible positions")
	failures += _check(game._resident_by_id("sua") != null and game._resident_by_id("dohyeon") != null and game._resident_by_id("gaeun") != null and game._resident_by_id("junho") != null and game._resident_by_id("daeun") != null and game._resident_by_id("taeo") != null and game._resident_by_id("somin") != null, "the seven additional residents can be looked up")
	var links_are_reciprocal := true
	for resident in game.residents:
		for other_id in resident.connections:
			var other := game._resident_by_id(str(other_id))
			links_are_reciprocal = links_are_reciprocal and other != null and other.connections.has(resident.resident_id)
	failures += _check(links_are_reciprocal and game._resident_by_id("sua").connections.has("junho"), "ten-resident starting relationships form a reciprocal town network")
	var yun_for_gossip: HaeondongResident = game._resident_by_id("yun")
	var yerin_for_gossip: HaeondongResident = game._resident_by_id("yerin")
	var minjae_for_gossip: HaeondongResident = game._resident_by_id("minjae")
	failures += _check(yerin_for_gossip.rumors.size() == 1 and float(yerin_for_gossip.rumors[0].get("confidence", 0.0)) == 0.85, "residents begin with only a small amount of second-hand town knowledge")
	game._open_dialogue(yerin_for_gossip)
	game._dialogue_action("news")
	failures += _check(game.dialogue_text.text.contains("민재") and game.dialogue_text.text.contains("윤에게"), "asking about town news reveals the resident's source")
	game._close_dialogue()
	var confidence_before_spread := float(yerin_for_gossip.rumors[0].get("confidence", 0.0))
	failures += _check(game._spread_rumor(yerin_for_gossip, minjae_for_gossip), "a known non-secret rumor can pass through a resident conversation")
	var passed_rumor: Dictionary = minjae_for_gossip.rumors[0] if not minjae_for_gossip.rumors.is_empty() else {}
	failures += _check(float(passed_rumor.get("confidence", 1.0)) < confidence_before_spread and str(passed_rumor.get("heard_from", "")) == "yerin", "retold rumors lose confidence and remember who retold them")
	failures += _check(not str(passed_rumor.get("text", "")).contains(yerin_for_gossip.private_worry), "private worries are excluded from rumor sharing")
	minjae_for_gossip.rumors.clear()
	for resident in game.residents:
		resident.location = resident.home
		resident.social_need = 0.0
	minjae_for_gossip.location = "공원"
	yerin_for_gossip.location = "공원"
	minjae_for_gossip.social_need = 60.0
	yerin_for_gossip.social_need = 60.0
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
	var journal_key := InputEventKey.new()
	journal_key.pressed = true
	journal_key.keycode = KEY_J
	game._unhandled_input(journal_key)
	failures += _check(game.journal_panel.visible, "J key opens the journal")
	var escape_key := InputEventKey.new()
	escape_key.pressed = true
	escape_key.keycode = KEY_ESCAPE
	game._unhandled_input(escape_key)
	failures += _check(not game.journal_panel.visible, "Escape closes the journal")
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

	var minjae: HaeondongResident = game._resident_by_id("minjae")
	game.player.global_position = game.PLACES["카페"]
	var money_before: int = game.money
	var minute_before: int = game.game_minute
	game._perform_action("work")
	failures += _check(game.money == money_before + 12, "working at the cafe pays the player")
	failures += _check(game.game_minute == minute_before + 120, "work advances two in-game hours")
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
	var save_uri: String = game.save_path
	game.queue_free()
	await get_tree().process_frame
	var restored := MAIN_SCRIPT.new()
	restored.save_path = test_save_path
	add_child(restored)
	await get_tree().process_frame
	var restored_yun: HaeondongResident = restored._resident_by_id("yun")
	failures += _check(restored.residents.size() == 10 and restored._resident_by_id("somin") != null, "all ten residents survive save and load")
	failures += _check(restored_yun.secret_shared_with_player and restored._resident_by_id("minjae").rumors.size() == 1, "private sharing and local rumor knowledge survive save and load")
	failures += _check(restored.money == saved_money, "player money survives save and load")
	failures += _check(restored_yun.player_affinity == saved_affinity, "resident relationship survives save and load")
	failures += _check(restored.inventory["책"] == 0, "inventory survives save and load")
	failures += _check(not restored.sound_enabled, "sound preference survives save and load")
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
