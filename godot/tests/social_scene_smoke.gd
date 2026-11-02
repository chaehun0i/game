extends SceneTree

const MAIN_SCRIPT := preload("res://scripts/main.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game = MAIN_SCRIPT.new()
	game.save_path = "user://social_scene_smoke_" + str(Time.get_ticks_usec()) + ".cfg"
	game.allow_external_services = false
	root.add_child(game)
	await process_frame
	var minjae = game._resident_by_id("minjae")
	var daeun = game._resident_by_id("daeun")
	minjae.visible = true
	daeun.visible = true
	minjae.location = "카페"
	daeun.location = "카페"
	minjae.global_position = Vector2(450, 240)
	daeun.global_position = Vector2(500, 240)
	game.player.global_position = Vector2(480, 280)
	var affinity_before: int = minjae.player_affinity
	var pair: Array[HaeondongResident] = [minjae, daeun]
	var pairs: Array[Array] = [pair]
	game._complete_evening_society(pairs)
	assert(game.social_scenes.size() == 1)
	var scene: Dictionary = game._social_scene_for_resident(minjae)
	assert(not scene.is_empty())
	assert(scene.get("dialogue", []).size() == 2)
	game._open_social_scene(scene)
	assert(game.dialogue_panel.visible)
	assert(not game.dialogue_input_row.visible)
	assert(game.social_scene_choices.visible)
	game._resolve_social_scene_choice("join")
	assert(game.dialogue_panel.visible)
	assert(game.dialogue_input_row.visible)
	assert(minjae.player_affinity == affinity_before + 1)
	assert(minjae.memories[0].contains("대화에 함께했다"))
	assert(daeun.memories[0].contains("대화에 함께했다"))
	assert(bool(game.world_events.back().get("player_known", false)))
	game._close_dialogue()
	var affinity_after_join: int = minjae.player_affinity
	game._complete_evening_society(pairs)
	scene = game._social_scene_for_resident(minjae)
	var heard_event_id := str(scene.get("event_id", ""))
	game._open_social_scene(scene)
	game._resolve_social_scene_choice("listen")
	assert(not game.dialogue_panel.visible)
	assert(minjae.player_affinity == affinity_after_join)
	assert(bool(game._world_event_by_id(heard_event_id).get("player_known", false)))
	game.player.global_position = Vector2(850, 500)
	game._complete_evening_society(pairs)
	scene = game._social_scene_for_resident(minjae)
	var passed_event_id := str(scene.get("event_id", ""))
	game._open_social_scene(scene)
	game._resolve_social_scene_choice("pass")
	assert(not game.dialogue_panel.visible)
	assert(not bool(game._world_event_by_id(passed_event_id).get("player_known", false)))
	game._save_world()
	game.queue_free()
	await process_frame
	print("Social scene smoke checks: passed")
	quit()
