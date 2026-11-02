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
var known_events: Array[String] = []
var memories: Array[String] = []
var rumors: Array[Dictionary] = []
var sprite_texture: Texture2D
var portrait_texture: Texture2D
var sprite_size := Vector2(28, 48)
var target_position := Vector2.ZERO
var walk_phase := 0.0
var idle_phase := 0.0
var walk_rate := 9.0
var walk_bounce := 1.2
var character_sprite: Sprite2D
var name_label: Label


func _ready() -> void:
	var motion_profiles := {
		"yun": Vector2(7.2, 0.65), "minjae": Vector2(10.8, 1.5), "yerin": Vector2(8.1, 0.8),
		"sua": Vector2(9.4, 1.05), "dohyeon": Vector2(11.4, 1.65), "gaeun": Vector2(9.0, 1.1),
		"junho": Vector2(10.2, 1.3), "daeun": Vector2(11.0, 1.7), "taeo": Vector2(8.5, 0.9), "somin": Vector2(7.8, 0.7)
	}
	var profile: Vector2 = motion_profiles.get(resident_id, Vector2(9.0, 1.0))
	walk_rate = profile.x
	walk_bounce = profile.y
	idle_phase = float(abs(resident_id.hash()) % 100) * 0.071
	character_sprite = Sprite2D.new()
	character_sprite.name = "CharacterSprite"
	character_sprite.centered = true
	character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	character_sprite.position.y = -sprite_size.y * 0.5
	character_sprite.z_index = 1
	add_child(character_sprite)
	name_label = Label.new()
	name_label.name = "NameTag"
	name_label.position = Vector2(-32, -sprite_size.y - 26)
	name_label.size = Vector2(64, 18)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color("fffaf0"))
	name_label.add_theme_color_override("font_shadow_color", Color(0.12, 0.17, 0.12, 0.9))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	name_label.z_index = 2
	add_child(name_label)
	refresh_visual()


func refresh_visual() -> void:
	if character_sprite != null:
		character_sprite.texture = sprite_texture
		if sprite_texture != null:
			sprite_size = sprite_texture.get_size()
		character_sprite.position.y = -sprite_size.y * 0.5
	if name_label != null:
		name_label.text = resident_name
		name_label.position.y = -sprite_size.y - 26


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
		walk_phase += delta * walk_rate
	else:
		position = target_position
		location = target_location
		idle_phase += delta * (1.1 + float(abs(resident_id.hash()) % 5) * 0.13)
	_animate_sprite()
	queue_redraw()


func _animate_sprite() -> void:
	if character_sprite == null:
		return
	var moving := position.distance_to(target_position) > 2.0
	var bob := sin(walk_phase) * walk_bounce if moving else sin(idle_phase) * 0.45
	character_sprite.position.y = -sprite_size.y * 0.5 + bob
	character_sprite.rotation = sin(walk_phase * 0.5) * 0.035 if moving else sin(idle_phase) * 0.009
	var direction := target_position.x - position.x
	if moving and absf(direction) > 1.0:
		character_sprite.flip_h = direction < 0.0


func _draw() -> void:
	draw_circle(Vector2(0, 1), 9.0, Color(0.14, 0.20, 0.16, 0.32))
	if sprite_texture == null:
		draw_rect(Rect2(-7, -13, 14, 12), color.darkened(0.12))
		draw_rect(Rect2(-5, -23, 10, 9), Color("f0d3b1"))
		draw_rect(Rect2(-6, -25, 12, 4), color.darkened(0.32))
