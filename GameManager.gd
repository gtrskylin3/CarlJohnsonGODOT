extends Node
@onready var kill_sound = $killaudio # Если это сценаmPlayer
@onready var coin_sound = $coinaudio # Если это сценаmPlayer
# Сигнал, который будет оповещать UI об изменениях
var kills: int = 0
var player_health: int = 100
signal kills_updated(new_count)
var total_coins: int = 0
signal coins_updated(new_count)
var kills_bs: int = 0
signal kills_bs_updated(new_count)
signal health_updated(new_health) # Сигнал для интерфейса

func update_health(amount: int):
	player_health += amount
	# Можно добавить проверку, чтобы HP не уходило в минус
	if player_health < 0: player_health = 0
	
	health_updated.emit(player_health) # Оповещаем UI
	
	if player_health <= 0:
		health_updated.emit("СМЕРТЬ")
		get_tree().reload_current_scene()

func add_coin(amount: int):
	total_coins += amount
	coin_sound.play(0.5)
	coins_updated.emit(total_coins)
	
	# Можно добавить звук подбора монеты здесь
	
func add_kill():
	kills += 1
	if kills % 5 == 0:
		kill_sound.play()
		
	kills_updated.emit(kills) # Отправляем сигнал всем, кто слушает

func add_bs_kill():
	kills_bs += 1
	if kills_bs % 5 == 0:
		kill_sound.play()
		
	kills_bs_updated.emit(kills_bs) # Отправляем сигнал всем, кто слушает
