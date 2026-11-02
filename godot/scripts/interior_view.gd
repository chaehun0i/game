class_name HaeondongInteriorView
extends Node2D

const CATALOG := preload("res://scripts/interior_catalog.gd")
const UI_INK := Color("354a37")

var current_place := ""
var background_texture: Texture2D


func show_place(place: String) -> void:
	current_place = place if CATALOG.has_interior(place) else ""
	visible = not current_place.is_empty()
	background_texture = load(CATALOG.background_path(current_place)) as Texture2D if visible else null
	if background_texture != null:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func _draw() -> void:
	if current_place.is_empty() or background_texture == null:
		return
	draw_texture_rect(background_texture, Rect2(0, 0, 960, 540), false)
	var layout: Dictionary = CATALOG.layout_for(current_place)
	var font := ThemeDB.fallback_font
	_draw_title(font)
	for object_data in layout.get("objects", []):
		_draw_interaction_label(font, object_data)
	_draw_exit_prompt(font)


func _draw_title(font: Font) -> void:
	var title := current_place + " 안"
	draw_rect(Rect2(16, 12, 194, 38), Color(0.16, 0.20, 0.16, 0.82))
	draw_string(font, Vector2(28, 38), title, HORIZONTAL_ALIGNMENT_LEFT, 160, 19, Color("fff1d7"))


func _draw_interaction_label(font: Font, object_data: Array) -> void:
	var name := str(object_data[0])
	var position: Vector2 = object_data[1]
	var label_width := font.get_string_size(name, HORIZONTAL_ALIGNMENT_CENTER, -1, 11).x
	var bounds := Rect2(position.x - maxf(42.0, label_width * 0.5 + 9.0), position.y + 32, maxf(84.0, label_width + 18.0), 20)
	draw_rect(bounds, Color(0.96, 0.92, 0.81, 0.91))
	draw_rect(bounds, Color(0.31, 0.40, 0.30, 0.70), false, 1.0)
	draw_string(font, Vector2(bounds.position.x + 7, bounds.position.y + 14), name, HORIZONTAL_ALIGNMENT_CENTER, bounds.size.x - 14, 11, UI_INK)


func _draw_exit_prompt(font: Font) -> void:
	draw_rect(Rect2(370, 492, 220, 32), Color(0.16, 0.20, 0.16, 0.84))
	draw_string(font, Vector2(385, 513), "E  밖으로 나가기", HORIZONTAL_ALIGNMENT_CENTER, 190, 13, Color("fff4dc"))
