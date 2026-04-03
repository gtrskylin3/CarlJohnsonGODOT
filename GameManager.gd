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

var is_reloading: bool = false # Флаг, чтобы не запускать перезагрузку дважды

func update_health(amount: int):
	# Если мы уже "умираем", урон больше не считаем
	if is_reloading: return 
	
	player_health += amount
	if player_health <= 0:
		player_health = 0
		die() # Выносим логику смерти в отдельный метод
	
	health_updated.emit(player_health)

func die():
	is_reloading = true
	health_updated.emit(0) # Отправляем UI сигнал "СМЕРТЬ"
	
	# Ждем 3 секунды
	await get_tree().create_timer(3.0).timeout
	
	# Сначала сбрасываем данные
	reset_game_stats()
	
	# Потом меняем сцену (безопасным методом)
	get_tree().call_deferred("change_scene_to_file", "res://scenes/World.tscn")
	
	is_reloading = false

func reset_game_stats():
	player_health = 100
	kills = 0
	kills_bs = 0
	total_coins = 0
	# Оповещаем UI, что всё обнулилось (по желанию)
	kills_updated.emit(0)
	coins_updated.emit(0)

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
