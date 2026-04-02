extends Node

func _on_start_pressed() -> void:
	# Загружаем основную сцену игры
	# Убедись, что путь к файлу совпадает с твоим (обычно это res://world.tscn)
	get_tree().change_scene_to_file("res://scenes/World.tscn")


func _on_exit_pressed() -> void:
	# Полностью закрываем приложение
	get_tree().quit()
