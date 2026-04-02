extends CanvasLayer

func _ready() -> void:
	# Показываем курсор, чтобы игрок мог нажать на кнопку
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Если игра была на паузе, титры должны работать (установи Process Mode в Always в инспекторе)

func _on_button_pressed() -> void:
	# 1. Скрываем слой с титрами
	get_tree().change_scene_to_file("res://scenes/End.tscn")
	# 3. ВАЖНО: Если ты ставил игру на паузу при показе титров, ее нужно снять
	
