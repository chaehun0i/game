class_name HaeondongResident
extends Node2D

var resident_id := ""
var resident_name := "이웃"
var role := ""
var home := "골목"
var workplace := "골목"
var location := "골목"
var color := Color("d6e3d1")
var schedule: Array[String] = []
var preferences: Array[String] = []
var goal := ""
var goal_progress := 0
var energy := 82.0
var social_need := 42.0
var hunger := 30.0
var money := 50
var daily_wage := 8
var player_affinity := 0
var memories: Array[String] = []
var target_position := Vector2.ZERO
var walk_phase := 0.0


func configure(data: Dictionary, start_position: Vector2) -> void:
	resident_id = str(data.get("id", ""))
	resident_name = str(data.get("name", "이웃"))
	role = str(data.get("role", ""))
	home = str(data.get("home", "골목"))
	workplace = str(data.get("workplace", home))
	location = home
	color = Color(str(data.get("color", "d6e3d1")))
	schedule.assign(data.get("schedule", []))
	preferences.assign(data.get("preferences", []))
	goal = str(data.get("goal", ""))
	position = start_position
	target_position = start_position
	z_index = 5


func set_destination(place: String, destination: Vector2) -> void:
	location = place
	target_position = destination


func _process(delta: float) -> void:
	var offset := target_position - position
	if offset.length() > 2.0:
		position += offset.normalized() * minf(34.0 * delta, offset.length())
		walk_phase += delta * 10.0
	else:
		position = target_position
	queue_redraw()


func _draw() -> void:
	var bob := roundi(sin(walk_phase) * 1.0) if position.distance_to(target_position) > 2.0 else 0
	draw_rect(Rect2(-8, 7, 16, 5), Color(0.20, 0.28, 0.22, 0.25))
	draw_rect(Rect2(-7, -1 + bob, 14, 11), color.darkened(0.12))
	draw_rect(Rect2(-6, 2 + bob, 12, 7), color)
	draw_rect(Rect2(-5, -10 + bob, 10, 9), Color("f0d3b1"))
	draw_rect(Rect2(-6, -12 + bob, 12, 4), color.darkened(0.32))
	draw_rect(Rect2(-3, -6 + bob, 2, 2), Color("3c342e"))
	draw_rect(Rect2(2, -6 + bob, 2, 2), Color("3c342e"))
	draw_rect(Rect2(-7, 9, 5, 3), Color("57463c"))
	draw_rect(Rect2(2, 9, 5, 3), Color("57463c"))
	draw_string(ThemeDB.fallback_font, Vector2(-24, -17), resident_name, HORIZONTAL_ALIGNMENT_CENTER, 48, 10, Color("fffaf0"))
