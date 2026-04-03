extends Label
var text_print = "ЗАМОЧЕНО ЗОМБИ: "

func _ready() -> void:
	# Подписываемся на сигнал из глобального менеджера
	GameManager.kills_updated.connect(_on_kills_updated)
	text = text_print + str(GameManager.kills) + " из 20"

func _on_kills_updated(new_count: int):
	# Обновляем текст, когда приходит сигнал
	if get_tree().current_scene.name == "World":
		var cur = GameManager.kills
		if cur < 20:
			text = text_print + str(GameManager.kills) + " из 20"
		else:
			text = "ДОБЕРИТЕСЬ ДО БИГ СМОКА"
	else:
		text = text_print + str(GameManager.kills)
