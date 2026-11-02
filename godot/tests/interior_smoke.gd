extends SceneTree

const MAIN_SCRIPT := preload("res://scripts/main.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game = MAIN_SCRIPT.new()
	game.save_path = "user://interior_smoke_world_" + str(Time.get_ticks_usec()) + ".cfg"
	game.allow_external_services = false
	root.add_child(game)
	await process_frame
	assert(game.INTERIOR_CATALOG.BACKGROUND_PATHS.size() == 9)
	for image_path in game.INTERIOR_CATALOG.BACKGROUND_PATHS.values():
		var room_art := load(str(image_path)) as Texture2D
		assert(room_art != null and room_art.get_width() == 960 and room_art.get_height() == 540)
	game.player.global_position = game.PLACES["카페"] + Vector2(0, -38)
	game._interact_nearby()
	assert(game.current_interior == "카페")
	assert(game.interior_view.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	assert(not game._resident_by_id("minjae").visible)
	game._leave_building()
	game._enter_building("집")
	game.player.global_position = Vector2(465, 190)
	game._interact_interior()
	assert(game.events[0].contains("창가 화분"))
	game._leave_building()
	game._enter_building("서점")
	game.player.global_position = Vector2(485, 365)
	var book_count: int = int(game.inventory.get("책", 0))
	game._interact_interior()
	assert(int(game.inventory.get("책", 0)) == book_count + 1)
	game._leave_building()
	game._enter_building("카페")
	game.player.global_position = Vector2(480, 420)
	game._interact_interior()
	assert(game.current_interior.is_empty())
	assert(game.player.global_position.distance_to(game.PLACES["카페"]) < 70.0)
	game._enter_building("집")
	game.player.global_position = Vector2(465, 190)
	game.day = 1
	game._interact_with_object("창가 화분", "plant")
	game._interact_with_object("창가 화분", "plant")
	assert(int(game.inventory["씨앗 봉투"]) == 0)
	game.day = 2
	game._interact_with_object("창가 화분", "plant")
	game.day = 3
	game._interact_with_object("창가 화분", "plant")
	assert(int(game.inventory["씨앗 봉투"]) == 1)
	game._leave_building()
	game._enter_building("꽃집")
	game.player.global_position = Vector2(190, 310)
	var sua = game._resident_by_id("sua")
	sua.location = "시장"
	game._interact_with_object("꽃 진열대", "flowers")
	assert(int(game.inventory["씨앗 봉투"]) == 1)
	sua.location = "꽃집"
	game._interact_with_object("꽃 진열대", "flowers")
	assert(int(game.inventory["씨앗 봉투"]) == 0)
	assert(int(game.inventory["압화 책갈피"]) == 1)
	assert(bool(game.hidden_routes["flowerbed_started"]))
	game._save_world()
	var restored = MAIN_SCRIPT.new()
	restored.save_path = game.save_path
	restored.controls_settings = load("res://scripts/controls_settings.gd").new()
	restored.controls_settings.initialize_defaults()
	restored._load_world()
	assert(int(restored.inventory["압화 책갈피"]) == 1)
	assert(bool(restored.hidden_routes["flowerbed_started"]))
	restored.free()
	game.current_interior = "도서관"
	var library_days := [4, 5, 6]
	for visit_day in library_days:
		game.day = visit_day
		game._record_daily_discovery("library_read", "낡은 시집", 3, "예린이 오래된 시집을 건넸어요.", ["yerin"])
	assert(int(game.inventory["낡은 시집"]) == 1)
	game.current_interior = "시장"
	for visit_day in [7, 8, 9]:
		game.day = visit_day
		game.game_minute = 8 * 60
		game._interact_with_object("채소 진열대", "produce")
	assert(int(game.inventory["준호의 레시피"]) == 1)
	game.current_interior = "우체국"
	for visit_day in [10, 11, 12]:
		game.day = visit_day
		game.game_minute = 19 * 60
		game._interact_with_object("우편함", "mailbox")
	assert(int(game.inventory["주소 없는 편지"]) == 1)
	var dohyeon = game._resident_by_id("dohyeon")
	dohyeon.location = "우체국"
	game._interact_with_object("분류 책상", "desk")
	assert(int(game.inventory["주소 없는 편지"]) == 0)
	assert(int(game.inventory["도현의 답장"]) == 1)
	game.current_interior = "카페"
	var minjae = game._resident_by_id("minjae")
	var daeun = game._resident_by_id("daeun")
	minjae.location = "카페"
	daeun.location = "카페"
	for visit_day in [13, 14]:
		game.day = visit_day
		game.game_minute = 19 * 60
		game._interact_with_object("작은 무대", "stage")
	assert(int(game.inventory["손글씨 악보"]) == 1)
	game.current_interior = "공방"
	for visit_day in [15, 16, 17]:
		game.day = visit_day
		game._interact_with_object("목공 작업대", "craft")
	assert(int(game.inventory["나무 단추"]) == 1)
	game.queue_free()
	await process_frame
	print("Interior smoke checks: passed")
	quit()
