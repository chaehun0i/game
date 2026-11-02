extends SceneTree

const PC_SMOKE_SCRIPT := preload("res://tests/pc_smoke.gd")


func _initialize() -> void:
	root.add_child(PC_SMOKE_SCRIPT.new())
