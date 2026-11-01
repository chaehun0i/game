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


static func load_atlas_region(path: String, index: int, columns: int, rows: int, height: int = 56) -> Texture2D:
	var source := load(path) as Texture2D
	if source == null or columns <= 0 or rows <= 0 or index < 0 or index >= columns * rows:
		return null
	var image := source.get_image()
	if image == null or image.is_empty() or image.get_width() % columns != 0 or image.get_height() % rows != 0:
		return null
	var cell_width := image.get_width() / columns
	var cell_height := image.get_height() / rows
	var cell := image.get_region(Rect2i((index % columns) * cell_width, (index / columns) * cell_height, cell_width, cell_height))
	var used_area := cell.get_used_rect()
	if used_area.size.x <= 0 or used_area.size.y <= 0:
		return null
	cell = cell.get_region(used_area)
	var width := maxi(18, roundi(float(height) * float(used_area.size.x) / float(used_area.size.y)))
	cell.resize(width, height, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(cell)
