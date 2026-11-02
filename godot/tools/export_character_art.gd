extends SceneTree

const PIXEL_SPRITE := preload("res://scripts/pixel_sprite.gd")
const ATLAS_PATH := "res://assets/residents_atlas.png"
const CHARACTER_DATA := {
	"player": {"name": "플레이어", "source": "res://assets/player.png"},
	"yun": {"name": "윤", "source": "res://assets/yun.png"},
	"minjae": {"name": "민재", "source": "res://assets/minjae.png"},
	"yerin": {"name": "예린", "source": "res://assets/yerin.png"},
	"sua": {"name": "수아", "index": 0},
	"dohyeon": {"name": "도현", "index": 1},
	"gaeun": {"name": "가은", "index": 2},
	"junho": {"name": "준호", "index": 3},
	"daeun": {"name": "다은", "index": 4},
	"taeo": {"name": "태오", "index": 5},
	"somin": {"name": "소민", "index": 6}
}


func _initialize() -> void:
	for character_id in CHARACTER_DATA:
		var entry: Dictionary = CHARACTER_DATA[character_id]
		var portrait: Texture2D
		var world_sprite: Texture2D
		if entry.has("source"):
			portrait = PIXEL_SPRITE.load_trimmed(str(entry.source), 320)
			world_sprite = PIXEL_SPRITE.load_trimmed(str(entry.source), 72)
		else:
			portrait = PIXEL_SPRITE.load_atlas_region(ATLAS_PATH, int(entry.index), 4, 2, 512)
			world_sprite = PIXEL_SPRITE.load_atlas_region(ATLAS_PATH, int(entry.index), 4, 2, 72)
		if portrait == null or world_sprite == null:
			push_error("캐릭터 이미지를 만들지 못했어요: " + character_id)
			quit(1)
			return
		var folder: String = "res://assets/characters/" + character_id
		var absolute_folder := ProjectSettings.globalize_path(folder)
		DirAccess.make_dir_recursive_absolute(absolute_folder)
		portrait.get_image().save_png(folder + "/portrait.png")
		world_sprite.get_image().save_png(folder + "/world_sprite.png")
		var manifest := {
			"id": character_id,
			"name": str(entry.name),
			"images": {"world": "world_sprite.png", "portrait": "portrait.png"},
			"motion_profile": "resident.gd의 인물별 걷기·숨쉬기 리듬"
		}
		var file := FileAccess.open(folder + "/character.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(manifest, "\t") + "\n")
	print("플레이어와 주민 10명의 전신·초상화 리소스를 만들었어요.")
	quit(0)
