extends Label
var text_print = "ЗАМОЧЕННО ЗОМБИ: "

func _ready() -> void:
	# Подписываемся на сигнал из глобального менеджера
	GameManager.kills_updated.connect(_on_kills_updated)
	text = text_print + str(GameManager.kills)

func _on_kills_updated(new_count: int):
	# Обновляем текст, когда приходит сигнал
	if get_tree().current_scene.name == "World":
		text = text_print + str(GameManager.kills) + " из 20"
	else:
		text = text_print + str(GameManager.kills)
