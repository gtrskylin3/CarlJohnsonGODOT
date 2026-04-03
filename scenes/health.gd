# --- Скрипт для Label ---
extends Label

func _ready():
	# Устанавливаем начальное значение
	text = "Health: " + str(GameManager.player_health)
	
	# Подписываемся на сигнал из менеджера
	GameManager.health_updated.connect(_on_health_updated)

func _on_health_updated(new_health):
	# Обновляем текст при получении сигнала
	text = "Health: " + str(new_health)
