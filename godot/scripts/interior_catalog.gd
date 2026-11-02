class_name HaeondongInteriorCatalog
extends RefCounted

# 해온동 건물 내부의 팔레트와 살펴볼 수 있는 물건을 한곳에서 관리합니다.
const LAYOUTS := {
	"집": {"floor": "d8c8a9", "wall": "8a7356", "objects": [["침대", Vector2(180, 270), "rest"], ["창가 화분", Vector2(465, 190), "plant"], ["책상", Vector2(820, 360), "desk"], ["부엌", Vector2(735, 240), "kitchen"]]},
	"서점": {"floor": "b7a27d", "wall": "6d5842", "objects": [["책장", Vector2(145, 240), "shelf"], ["책 교환 서가", Vector2(485, 365), "book_exchange"], ["계산대", Vector2(760, 260), "counter"]]},
	"우체국": {"floor": "b9c9c4", "wall": "607b75", "objects": [["우편함", Vector2(575, 185), "mailbox"], ["분류 책상", Vector2(205, 310), "desk"], ["대기 의자", Vector2(855, 420), "seat"]]},
	"학교": {"floor": "c6c3a6", "wall": "6d7655", "objects": [["칠판", Vector2(520, 145), "blackboard"], ["교실 책상", Vector2(565, 385), "desk"], ["책장", Vector2(165, 255), "shelf"]]},
	"시장": {"floor": "c9b887", "wall": "816c43", "objects": [["채소 진열대", Vector2(285, 350), "produce"], ["저울", Vector2(490, 180), "scale"], ["간식 바구니", Vector2(780, 360), "snack"]]},
	"카페": {"floor": "cbb6a0", "wall": "765b4b", "objects": [["주문대", Vector2(275, 250), "counter"], ["커피 머신", Vector2(315, 175), "coffee"], ["창가 자리", Vector2(170, 390), "seat"], ["작은 무대", Vector2(780, 220), "stage"]]},
	"꽃집": {"floor": "d4baa9", "wall": "8e6471", "objects": [["꽃 진열대", Vector2(190, 310), "flowers"], ["꽃가위", Vector2(485, 390), "tools"], ["포장대", Vector2(700, 280), "counter"]]},
	"도서관": {"floor": "c3b992", "wall": "786846", "objects": [["소설 서가", Vector2(135, 270), "shelf"], ["창가 독서석", Vector2(480, 380), "read"], ["자료 검색대", Vector2(745, 280), "catalog"]]},
	"공방": {"floor": "bca98b", "wall": "78674e", "objects": [["목공 작업대", Vector2(485, 370), "craft"], ["공구 벽", Vector2(615, 175), "tools"], ["완성품 선반", Vector2(840, 320), "shelf"]]}
}
const BACKGROUND_PATHS := {
	"집": "res://assets/interiors/home.png",
	"서점": "res://assets/interiors/bookstore.png",
	"우체국": "res://assets/interiors/post_office.png",
	"학교": "res://assets/interiors/school.png",
	"시장": "res://assets/interiors/market.png",
	"카페": "res://assets/interiors/cafe.png",
	"꽃집": "res://assets/interiors/flower_shop.png",
	"도서관": "res://assets/interiors/library.png",
	"공방": "res://assets/interiors/workshop.png"
}


static func has_interior(place: String) -> bool:
	return LAYOUTS.has(place)


static func layout_for(place: String) -> Dictionary:
	return LAYOUTS.get(place, LAYOUTS["집"])


static func background_path(place: String) -> String:
	return str(BACKGROUND_PATHS.get(place, BACKGROUND_PATHS["집"]))


static func entrance_for(place: String, outdoor_position: Vector2) -> Vector2:
	return outdoor_position + Vector2(0, 42 if outdoor_position.y < 300.0 else -38)


static func exit_for(place: String, outdoor_position: Vector2) -> Vector2:
	return outdoor_position + Vector2(0, 52 if outdoor_position.y < 300.0 else -48)


static func nearest_object(place: String, position: Vector2, max_distance: float = 78.0) -> Array:
	if not has_interior(place):
		return []
	var nearest: Array = []
	var nearest_distance := max_distance
	for object_data in LAYOUTS[place].get("objects", []):
		var distance: float = position.distance_to(object_data[1])
		if distance < nearest_distance:
			nearest = object_data
			nearest_distance = distance
	return nearest
