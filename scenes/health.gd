# --- Скрипт для Label ---
extends Label
@onready var death: TextureRect = $death

func _ready():
	# Устанавливаем начальное значение
	death.visible = false
	text = "Health: " + str(GameManager.player_health)
	
	# Подписываемся на сигнал из менеджера
	GameManager.health_updated.connect(_on_health_updated)

func _on_health_updated(new_health):
	# Обновляем текст при получении сигнала
	if new_health == 0:
		text = "ПОТРАЧЕНО"
		death.visible = true
	else:
		text = "Health: " + str(new_health)
