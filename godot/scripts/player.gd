class_name HaeondongPlayer
extends CharacterBody2D

const WALK_SPEED := 150.0
const OUTFIT_NAMES := ["겨자빛", "솔잎 초록", "벽돌빛", "바다 파랑", "라벤더"]
const OUTFIT_COLORS := [Color("d99a30"), Color("60836b"), Color("b96c55"), Color("6688a0"), Color("987da7")]
const OUTFIT_SHADER := preload("res://shaders/player_outfit.gdshader")

var click_destination := Vector2.INF
var walk_phase := 0.0
var sprite_texture: Texture2D
var walk_textures: Array[Texture2D] = []
var sprite_size := Vector2(30, 48)
var interior_mode := false
var display_name := "나"
var outfit_style := 0
var character_sprite: Sprite2D
var name_label: Label
var breath_phase := 0.0
var reduce_motion := false


func _ready() -> void:
	character_sprite = Sprite2D.new()
	character_sprite.name = "CharacterSprite"
	character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	character_sprite.centered = true
	character_sprite.position.y = -sprite_size.y * 0.5
	character_sprite.z_index = 1
	add_child(character_sprite)
	character_sprite.material = create_outfit_material()
	name_label = Label.new()
	name_label.name = "NameTag"
	name_label.position = Vector2(-44, -sprite_size.y - 27)
	name_label.size = Vector2(88, 20)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color("fff7df"))
	name_label.add_theme_color_override("font_shadow_color", Color(0.12, 0.17, 0.12, 0.9))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	name_label.z_index = 2
	add_child(name_label)
	set_appearance(display_name, outfit_style)
	_refresh_sprite()


func set_appearance(new_name: String, style_index: int) -> void:
	display_name = new_name.strip_edges() if not new_name.strip_edges().is_empty() else "나"
	outfit_style = clampi(style_index, 0, OUTFIT_NAMES.size() - 1)
	if name_label != null:
		name_label.text = display_name
	if character_sprite != null and character_sprite.material is ShaderMaterial:
		(character_sprite.material as ShaderMaterial).set_shader_parameter("jacket_color", OUTFIT_COLORS[outfit_style])
	queue_redraw()


func set_reduce_motion(enabled: bool) -> void:
	reduce_motion = enabled
	if reduce_motion and character_sprite != null:
		character_sprite.rotation = 0.0


func outfit_preview_tint() -> Color:
	return Color.WHITE


func create_outfit_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = OUTFIT_SHADER
	material.set_shader_parameter("jacket_color", OUTFIT_COLORS[outfit_style])
	return material


func set_interior_mode(enabled: bool) -> void:
	interior_mode = enabled


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("move_right"):
		direction.x += 1.0
	if Input.is_action_pressed("move_up"):
		direction.y -= 1.0
	if Input.is_action_pressed("move_down"):
		direction.y += 1.0

	if direction.length_squared() > 0.0:
		click_destination = Vector2.INF
		velocity = direction.normalized() * WALK_SPEED
	elif click_destination != Vector2.INF:
		var to_destination := click_destination - global_position
		var destination_distance_squared := to_destination.length_squared()
		if destination_distance_squared <= 25.0:
			click_destination = Vector2.INF
			velocity = Vector2.ZERO
		else:
			velocity = to_destination * (WALK_SPEED / sqrt(destination_distance_squared))
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	z_index = roundi(global_position.y)
	global_position.x = clampf(global_position.x, 54.0, 906.0 if interior_mode else 926.0)
	global_position.y = clampf(global_position.y, 92.0, 468.0 if interior_mode else 510.0)
	if velocity.length_squared() > 1.0:
		walk_phase += delta * 12.0
	else:
		breath_phase += delta * 2.1
	_animate_sprite()


func walk_to(destination: Vector2) -> void:
	click_destination = destination


func _refresh_sprite() -> void:
	if character_sprite == null:
		return
	character_sprite.texture = sprite_texture
	if sprite_texture != null:
		sprite_size = sprite_texture.get_size()
		character_sprite.position.y = -sprite_size.y * 0.5
	if name_label != null:
		name_label.position.y = -sprite_size.y - 27


func _animate_sprite() -> void:
	if character_sprite == null:
		return
	if reduce_motion:
		character_sprite.texture = sprite_texture
		character_sprite.position.y = -sprite_size.y * 0.5
		character_sprite.rotation = 0.0
		if absf(velocity.x) > 1.0:
			character_sprite.flip_h = velocity.x < 0.0
		return
	var moving := velocity.length_squared() > 1.0
	if moving and not walk_textures.is_empty():
		var frame_index := posmod(floori(walk_phase / (TAU / float(walk_textures.size()))), walk_textures.size())
		character_sprite.texture = walk_textures[frame_index]
	else:
		character_sprite.texture = sprite_texture
	var bob := sin(walk_phase) * (2.0 if moving else 0.65 + sin(breath_phase) * 0.4)
	character_sprite.position.y = -sprite_size.y * 0.5 + bob
	character_sprite.rotation = sin(walk_phase * 0.5) * 0.045 if moving else sin(breath_phase) * 0.012
	if absf(velocity.x) > 1.0:
		character_sprite.flip_h = velocity.x < 0.0


func _draw() -> void:
	draw_circle(Vector2(0, 1), 10.0, Color(0.14, 0.20, 0.16, 0.34))
	if sprite_texture == null:
		draw_rect(Rect2(-7, -13, 14, 12), OUTFIT_COLORS[outfit_style])
		draw_rect(Rect2(-5, -23, 10, 9), Color("f1d4b2"))
		draw_rect(Rect2(-6, -25, 12, 4), Color("344c3a"))
