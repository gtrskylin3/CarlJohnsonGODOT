extends Label
var text_print = "ЗАМОЧЕННО Big smokkov: "
func _ready() -> void:
	# Подписываемся на сигнал из глобального менеджера
	GameManager.kills_bs_updated.connect(_on_kills_bs_updated)
	# Устанавливаем начальное значение
	text = text_print + str(GameManager.kills_bs)

func _on_kills_bs_updated(new_count: int):
	# Обновляем текст, когда приходит сигнал
	text = text_print  + str(new_count)
