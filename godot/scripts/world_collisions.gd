extends Node2D

const INTERIOR_CATALOG := preload("res://scripts/interior_catalog.gd")

const UPPER_BUILDINGS := [
	{"name": "집", "center": Vector2(86, 150), "size": Vector2(132, 104)},
	{"name": "서점", "center": Vector2(287, 150), "size": Vector2(166, 104)},
	{"name": "우체국", "center": Vector2(635, 153), "size": Vector2(130, 110)},
	{"name": "학교", "center": Vector2(845, 155), "size": Vector2(204, 116)}
]

const LOWER_BUILDINGS := [
	{"name": "시장", "left": 38.0, "right": 210.0, "door": 128.0},
	{"name": "카페", "left": 208.0, "right": 370.0, "door": 291.0},
	{"name": "공방", "left": 394.0, "right": 574.0, "door": 488.0},
	{"name": "꽃집", "left": 604.0, "right": 760.0, "door": 682.0},
	{"name": "도서관", "left": 762.0, "right": 952.0, "door": 845.0}
]

const WALKABLE_POINTS := [
	Vector2(385, 230), Vector2(86, 230), Vector2(287, 230), Vector2(635, 230), Vector2(845, 230),
	Vector2(86, 270), Vector2(287, 270), Vector2(635, 270), Vector2(845, 270),
	Vector2(128, 365), Vector2(291, 365), Vector2(488, 365), Vector2(682, 365), Vector2(845, 365),
	Vector2(128, 430), Vector2(291, 430), Vector2(488, 430), Vector2(682, 430), Vector2(845, 430),
	Vector2(477, 190)
]

const WALKABLE_CONNECTIONS := [
	[0, 1], [0, 2], [0, 3], [0, 4], [1, 2], [2, 3], [3, 4],
	[1, 5], [2, 6], [3, 7], [4, 8], [5, 6], [6, 7], [7, 8],
	[5, 9], [6, 10], [7, 11], [8, 12], [9, 10], [10, 11], [11, 12],
	[9, 13], [10, 14], [11, 15], [12, 16], [13, 14], [14, 15], [15, 16],
	[0, 19], [19, 5], [19, 6], [19, 7], [19, 8]
]

const BLOCKED_ROUTE_RADIUS := 72.0

var interior_colliders: Array[StaticBody2D] = []
var world_colliders: Array[StaticBody2D] = []


func _ready() -> void:
	_build_world_bounds()
	_build_building_colliders()


func show_interior(place: String) -> void:
	_clear_interior()
	if not INTERIOR_CATALOG.has_interior(place):
		return
	for object_data in INTERIOR_CATALOG.layout_for(place).get("objects", []):
		var object_name := str(object_data[0])
		var object_position: Vector2 = object_data[1]
		var action := str(object_data[2])
		_add_circle(
			"실내 장애물 · " + object_name,
			object_position,
			_interaction_radius(action),
			interior_colliders
		)


func clear_interior() -> void:
	_clear_interior()


func route_for(start: Vector2, destination: Vector2) -> PackedVector2Array:
	var points: Array[Vector2] = [start, destination]
	var graph: Array[Array] = []
	for _point in WALKABLE_POINTS:
		graph.append([])
	for connection in WALKABLE_CONNECTIONS:
		var first := int(connection[0])
		var second := int(connection[1])
		if not _is_route_blocked(WALKABLE_POINTS[first], WALKABLE_POINTS[second]):
			graph[first].append(second)
			graph[second].append(first)

	var start_node := _closest_walkable_index(start)
	var end_node := _closest_walkable_index(destination)
	if start_node < 0 or end_node < 0:
		return PackedVector2Array([destination])
	var frontier: Array[int] = [start_node]
	var parent: Dictionary = {start_node: -1}
	while not frontier.is_empty() and not parent.has(end_node):
		var current: int = frontier.pop_front()
		for neighbor in graph[current]:
			if parent.has(neighbor):
				continue
			parent[neighbor] = current
			frontier.append(neighbor)
	if not parent.has(end_node):
		return PackedVector2Array([destination])

	var reversed_route: Array[Vector2] = [WALKABLE_POINTS[end_node]]
	var cursor := end_node
	while int(parent[cursor]) >= 0:
		cursor = int(parent[cursor])
		reversed_route.append(WALKABLE_POINTS[cursor])
	reversed_route.reverse()
	var route := PackedVector2Array()
	for waypoint in reversed_route:
		if waypoint.distance_to(start) > 8.0 and waypoint.distance_to(destination) > 8.0:
			route.append(waypoint)
	route.append(destination)
	return route


func _closest_walkable_index(position: Vector2) -> int:
	var closest_index := -1
	var closest_distance := BLOCKED_ROUTE_RADIUS
	for index in WALKABLE_POINTS.size():
		var distance := position.distance_to(WALKABLE_POINTS[index])
		if distance < closest_distance and not _is_point_blocked(WALKABLE_POINTS[index]):
			closest_distance = distance
			closest_index = index
	return closest_index


func _is_route_blocked(start: Vector2, destination: Vector2) -> bool:
	var sample_count := maxi(2, ceili(start.distance_to(destination) / 12.0))
	for sample_index in sample_count + 1:
		var sample := start.lerp(destination, float(sample_index) / float(sample_count))
		if _is_point_blocked(sample):
			return true
	return false


func _is_point_blocked(point: Vector2) -> bool:
	for building in UPPER_BUILDINGS:
		var rect := Rect2(building["center"] - building["size"] * 0.5, building["size"]).grow(12.0)
		if rect.has_point(point):
			return true
	for building in LOWER_BUILDINGS:
		var left := float(building["left"])
		var right := float(building["right"])
		var door := float(building["door"])
		if point.x < left or point.x > right:
			continue
		if point.y >= 312.0 and point.y <= 405.0 and absf(point.x - door) > 36.0:
			return true
	return point.distance_to(Vector2(477, 157)) < 30.0


func _build_world_bounds() -> void:
	_add_rectangle("지도 위쪽 경계", Vector2(480, -12), Vector2(1000, 24))
	_add_rectangle("지도 아래쪽 경계", Vector2(480, 552), Vector2(1000, 24))
	_add_rectangle("지도 왼쪽 경계", Vector2(-12, 270), Vector2(24, 600))
	_add_rectangle("지도 오른쪽 경계", Vector2(972, 270), Vector2(24, 600))
	_add_circle("공원 큰 나무", Vector2(477, 157), 17.0, world_colliders)


func _build_building_colliders() -> void:
	for building in UPPER_BUILDINGS:
		_add_rectangle(
			str(building["name"]) + " 건물",
			building["center"],
			building["size"]
		)

	for building in LOWER_BUILDINGS:
		var left := float(building["left"])
		var right := float(building["right"])
		var door := float(building["door"])
		_add_rectangle(
			str(building["name"]) + " 건물 뒷벽",
			Vector2((left + right) * 0.5, 320),
			Vector2(right - left, 14)
		)
		_add_rectangle(
			str(building["name"]) + " 왼쪽 벽",
			Vector2(left + 7.0, 364),
			Vector2(14, 74)
		)
		_add_rectangle(
			str(building["name"]) + " 오른쪽 벽",
			Vector2(right - 7.0, 364),
			Vector2(14, 74)
		)
		_add_rectangle(
			str(building["name"]) + " 문턱",
			Vector2(door, 405),
			Vector2(72, 4)
		)


func _interaction_radius(action: String) -> float:
	return float({
		"counter": 19, "coffee": 13, "seat": 18, "stage": 22,
		"shelf": 19, "book_exchange": 17, "blackboard": 22,
		"read": 18, "catalog": 17, "craft": 21, "tools": 17,
		"kitchen": 20, "desk": 18, "rest": 20, "plant": 15,
		"mailbox": 15, "produce": 18, "snack": 16, "scale": 14,
		"flowers": 17
	}.get(action, 15))


func _add_rectangle(label: String, center: Vector2, dimensions: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = label
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = dimensions
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	body.position = center
	add_child(body)
	return body


func _add_circle(
	label: String,
	center: Vector2,
	radius: float,
	owner: Array[StaticBody2D]
) -> void:
	var body := StaticBody2D.new()
	body.name = label
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CircleShape2D.new()
	shape.radius = radius
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	body.position = center
	add_child(body)
	owner.append(body)


func _clear_interior() -> void:
	for body in interior_colliders:
		if is_instance_valid(body):
			body.free()
	interior_colliders.clear()
