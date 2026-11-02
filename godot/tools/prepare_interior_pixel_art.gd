extends SceneTree

# 실내 배경을 게임 화면의 픽셀 그리드에 맞춰 한 번 정리합니다.
const SOURCE_DIRECTORY := "res://assets/interiors"
const OUTPUT_WIDTH := 960
const OUTPUT_HEIGHT := 540
const PIXEL_WIDTH := 320
const PIXEL_HEIGHT := 180
const FILE_NAMES := [
	"home.png",
	"bookstore.png",
	"post_office.png",
	"school.png",
	"market.png",
	"cafe.png",
	"flower_shop.png",
	"library.png",
	"workshop.png",
]


func _initialize() -> void:
	for file_name in FILE_NAMES:
		var file_path := SOURCE_DIRECTORY.path_join(file_name)
		var image := Image.new()
		var load_result := image.load(file_path)
		if load_result != OK:
			push_error("실내 이미지를 읽지 못했습니다: " + file_path)
			quit(1)
			return

		# 320x180에서 색을 정리한 뒤 3배 확대해 일정한 픽셀 크기를 만듭니다.
		image.resize(PIXEL_WIDTH, PIXEL_HEIGHT, Image.INTERPOLATE_NEAREST)
		_reduce_color_steps(image)
		image.resize(OUTPUT_WIDTH, OUTPUT_HEIGHT, Image.INTERPOLATE_NEAREST)
		var save_result := image.save_png(file_path)
		if save_result != OK:
			push_error("실내 이미지를 저장하지 못했습니다: " + file_path)
			quit(1)
			return

	print("실내 배경 9장을 320x180 픽셀 그리드 기준으로 정리했습니다.")
	quit()


func _reduce_color_steps(image: Image) -> void:
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color := image.get_pixel(x, y)
			color.r = round(color.r * 15.0) / 15.0
			color.g = round(color.g * 15.0) / 15.0
			color.b = round(color.b * 15.0) / 15.0
			image.set_pixel(x, y, color)
