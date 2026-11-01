class_name HaeondongPlayer
extends CharacterBody2D

const WALK_SPEED := 150.0
var click_destination := Vector2.INF
var walk_phase := 0.0


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1.0

	if direction.length_squared() > 0.0:
		click_destination = Vector2.INF
		velocity = direction.normalized() * WALK_SPEED
	elif click_destination != Vector2.INF:
		var to_destination := click_destination - global_position
		if to_destination.length() <= 5.0:
			click_destination = Vector2.INF
			velocity = Vector2.ZERO
		else:
			velocity = to_destination.normalized() * WALK_SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	global_position.x = clampf(global_position.x, 34.0, 926.0)
	global_position.y = clampf(global_position.y, 70.0, 510.0)
	if velocity.length_squared() > 1.0:
		walk_phase += delta * 12.0
	queue_redraw()


func walk_to(destination: Vector2) -> void:
	click_destination = destination


func _draw() -> void:
	var bob := roundi(sin(walk_phase) * 1.5) if velocity.length_squared() > 1.0 else 0
	draw_rect(Rect2(-9, 7, 18, 5), Color(0.20, 0.28, 0.22, 0.28))
	draw_rect(Rect2(-7, -1 + bob, 14, 12), Color("547d64"))
	draw_rect(Rect2(-6, 3 + bob, 12, 7), Color("e9cf9d"))
	draw_rect(Rect2(-5, -11 + bob, 10, 9), Color("f1d4b2"))
	draw_rect(Rect2(-6, -13 + bob, 12, 4), Color("344c3a"))
	draw_rect(Rect2(-3, -7 + bob, 2, 2), Color("3b332d"))
	draw_rect(Rect2(2, -7 + bob, 2, 2), Color("3b332d"))
	draw_rect(Rect2(-7, 10, 5, 3), Color("493e37"))
	draw_rect(Rect2(2, 10, 5, 3), Color("493e37"))
	draw_string(ThemeDB.fallback_font, Vector2(-6, -18), "나", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("fff8df"))
