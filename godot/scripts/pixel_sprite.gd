extends RefCounted
class_name PixelSprite


static func load_trimmed(path: String, height: int = 48) -> Texture2D:
	var source := load(path) as Texture2D
	if source == null:
		return null
	var image := source.get_image()
	if image == null or image.is_empty():
		return source
	var used_area := image.get_used_rect()
	if used_area.size.x <= 0 or used_area.size.y <= 0:
		return source
	image = image.get_region(used_area)
	var width := maxi(18, roundi(float(height) * float(used_area.size.x) / float(used_area.size.y)))
	image.resize(width, height, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)
