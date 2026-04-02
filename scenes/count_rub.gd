extends Label
func _ready() -> void:
	# Подписываемся на сигнал из глобального менеджера
	GameManager.coins_updated.connect(_on_coins_updated)
	# Устанавливаем начальное значение
	text = "Заработано рублей: " + str(GameManager.kills)

func _on_coins_updated(new_count: int):
	# Обновляем текст, когда приходит сигнал
	text = "Заработано рублей: " + str(new_count)
