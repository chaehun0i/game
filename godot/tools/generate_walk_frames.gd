extends SceneTree

# 기존 투명 스프라이트의 다리 부분만 움직여 간단한 보행 프레임을 만듭니다.
const CHARACTER_IDS := [
	"player", "yun", "minjae", "yerin", "sua", "dohyeon",
	"gaeun", "junho", "daeun", "taeo", "somin",
]
const FRAME_COUNT := 4


func _initialize() -> void:
	for character_id in CHARACTER_IDS:
		var folder: String = "res://assets/characters/" + character_id
		var source := Image.new()
		var load_error := source.load(folder + "/world_sprite.png")
		if load_error != OK:
			push_error("걷기 프레임 원본을 읽지 못했습니다: " + character_id)
			quit(1)
			return

		var frames: Array[Image] = [
			source.duplicate(),
			_make_stride(source, -2, 2, -1, 1),
			source.duplicate(),
			_make_stride(source, 2, -2, 1, -1),
		]
		for frame_index in FRAME_COUNT:
			var output_path: String = folder + "/walk_%d.png" % frame_index
			if frames[frame_index].save_png(output_path) != OK:
				push_error("걷기 프레임을 저장하지 못했습니다: " + output_path)
				quit(1)
				return
	print("인물 11명의 4프레임 보행 이미지를 만들었습니다.")
	quit()


func _make_stride(source: Image, left_dx: int, right_dx: int, left_dy: int, right_dy: int) -> Image:
	var frame := source.duplicate()
	var center_x := floori(float(source.get_width()) / 2.0)
	var leg_top := maxi(0, source.get_height() - 18)
	var leg_height := source.get_height() - leg_top
	var left_rect := Rect2i(center_x - 20, leg_top, 20, leg_height)
	var right_rect := Rect2i(center_x, leg_top, 20, leg_height)
	frame.fill_rect(left_rect, Color.TRANSPARENT)
	frame.fill_rect(right_rect, Color.TRANSPARENT)
	frame.blit_rect(source, left_rect, Vector2i(left_rect.position.x + left_dx, leg_top + left_dy))
	frame.blit_rect(source, right_rect, Vector2i(right_rect.position.x + right_dx, leg_top + right_dy))
	return frame
