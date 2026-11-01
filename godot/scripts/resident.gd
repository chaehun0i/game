class_name HaeondongResident
extends Node2D

var resident_id := ""
var resident_name := "이웃"
var role := ""
var home := "골목"
var workplace := "골목"
var location := "골목"
var target_location := "골목"
var color := Color("d6e3d1")
var schedule: Array[String] = []
var preferences: Array[String] = []
var traits: Array[String] = []
var values: Array[String] = []
var background := ""
var goal := ""
var private_worry := ""
var goal_progress := 0
var last_goal_step_day := 0
var energy := 82.0
var social_need := 42.0
var hunger := 30.0
var money := 50
var daily_wage := 8
var player_affinity := 0
var last_contact_day := 0
var last_gift_day := 0
var secret_shared_with_player := false
var milestone_reached := false
var connections: Dictionary = {}
var last_social_partner_id := ""
var last_social_day := 0
var memories: Array[String] = []
var rumors: Array[Dictionary] = []
var sprite_texture: Texture2D
var portrait_texture: Texture2D
var sprite_size := Vector2(28, 48)
var target_position := Vector2.ZERO
var walk_phase := 0.0


func configure(data: Dictionary, start_position: Vector2) -> void:
	resident_id = str(data.get("id", ""))
	resident_name = str(data.get("name", "이웃"))
	role = str(data.get("role", ""))
	home = str(data.get("home", "골목"))
	workplace = str(data.get("workplace", home))
	location = home
	target_location = home
	color = Color(str(data.get("color", "d6e3d1")))
	schedule.assign(data.get("schedule", []))
	preferences.assign(data.get("preferences", []))
	goal = str(data.get("goal", ""))
	private_worry = str(data.get("private_worry", ""))
	position = start_position
	target_position = start_position
	z_index = 5


func set_destination(place: String, destination: Vector2) -> void:
	target_location = place
	target_position = destination
	queue_redraw()


func _process(delta: float) -> void:
	z_index = roundi(global_position.y)
	var offset := target_position - position
	if offset.length() > 2.0:
		position += offset.normalized() * minf(82.0 * delta, offset.length())
		walk_phase += delta * 10.0
	else:
		position = target_position
		location = target_location
	queue_redraw()


func _draw() -> void:
	var bob := roundi(sin(walk_phase) * 1.0) if position.distance_to(target_position) > 2.0 else 0
	draw_circle(Vector2(0, 1), 9.0, Color(0.14, 0.20, 0.16, 0.32))
	if sprite_texture != null:
		draw_texture_rect(sprite_texture, Rect2(-sprite_size.x / 2.0, -sprite_size.y + bob, sprite_size.x, sprite_size.y), false)
	else:
		draw_rect(Rect2(-7, -1 + bob, 14, 11), color.darkened(0.12))
		draw_rect(Rect2(-6, 2 + bob, 12, 7), color)
		draw_rect(Rect2(-5, -10 + bob, 10, 9), Color("f0d3b1"))
		draw_rect(Rect2(-6, -12 + bob, 12, 4), color.darkened(0.32))
	draw_rect(Rect2(-22, -64, 44, 14), Color(0.14, 0.20, 0.16, 0.82))
	draw_string(ThemeDB.fallback_font, Vector2(-22, -53), resident_name, HORIZONTAL_ALIGNMENT_CENTER, 44, 10, Color("fffaf0"))
