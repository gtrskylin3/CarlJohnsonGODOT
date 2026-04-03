extends Node3D

var rotation_speed: float = 2
func _process(delta: float) -> void:
	# Красивое вращение
	rotate_y(rotation_speed * delta)
