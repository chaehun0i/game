class_name HaeondongCalendar
extends RefCounted

const DAYS_PER_SEASON := 28
const SEASONS_PER_YEAR := 4
const DAYS_PER_YEAR := DAYS_PER_SEASON * SEASONS_PER_YEAR
const SEASON_NAMES := ["봄", "여름", "가을", "겨울"]


static func date_for_day(world_day: int) -> Dictionary:
	var safe_day := maxi(1, world_day)
	var year_day := posmod(safe_day - 1, DAYS_PER_YEAR) + 1
	var season_index := floori(float(year_day - 1) / DAYS_PER_SEASON)
	return {
		"year": floori(float(safe_day - 1) / DAYS_PER_YEAR) + 1,
		"year_day": year_day,
		"season_index": season_index,
		"season": SEASON_NAMES[season_index],
		"season_day": posmod(year_day - 1, DAYS_PER_SEASON) + 1
	}


static func event_for_day(world_day: int) -> Dictionary:
	var date := date_for_day(world_day)
	if int(date["year_day"]) == DAYS_PER_YEAR:
		return {
			"kind": "year_end",
			"key": "year_%d_end" % int(date["year"]),
			"year": int(date["year"]),
			"season": "겨울",
			"title": "해온동에서 보낸 한 해",
			"place": "공원",
			"image": "year_end_gathering.png"
		}
	if int(date["season_day"]) != 14:
		return {}
	var gatherings := [
		{"title": "봄날의 작은 소풍", "place": "공원", "image": "festival_spring.png"},
		{"title": "골목의 여름 저녁", "place": "카페", "image": "festival_summer.png"},
		{"title": "가을 한 끼 나눔", "place": "시장", "image": "festival_autumn.png"},
		{"title": "겨울 책과 따뜻한 차", "place": "도서관", "image": "year_end_gathering.png"}
	]
	var season_index: int = date["season_index"]
	var gathering: Dictionary = gatherings[season_index]
	return {
		"kind": "seasonal",
		"key": "year_%d_season_%d" % [int(date["year"]), season_index],
		"year": int(date["year"]),
		"season": str(date["season"]),
		"title": str(gathering["title"]),
		"place": str(gathering["place"]),
		"image": str(gathering["image"])
	}
