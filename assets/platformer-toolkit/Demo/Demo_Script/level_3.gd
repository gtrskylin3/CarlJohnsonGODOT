extends Control

@export var Menu: PackedScene

func _on_timer_timeout() -> void:
	get_tree().call_deferred("change_scene_to_packed", Menu)
