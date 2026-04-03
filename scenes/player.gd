extends CharacterBody3D

const SPEED = 5.0
const RUN = 4.0
const JUMP_VELOCITY = 6
const MOUSE_SENSITIVITY = 0.003

@onready var anim_player: AnimationPlayer = $Visuals/CarlJohnson/AnimationPlayer2
@onready var visuals: Node3D = $Visuals
@onready var attack_sound: AudioStreamPlayer = $attacksound
@onready var camera_origin: Node3D = $CamOrigin
@onready var camera: Camera3D = $CamOrigin/Camera3D
@onready var damage_sound: AudioStreamPlayer = $AudioStreamPlayer

var current_anim: String = ""
var attack_cooldown: float = 0.0
const ATTACK_DAMAGE: int = 3
const ATTACK_RATE: float = 0.6   # время между атаками (в секундах)
var health: int = 100

func _ready() -> void:
	# ВКЛЮЧАЕМ РЕЖИМ ЗАХВАТА: мышь исчезает и не упирается в края экрана
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		get_tree().change_scene_to_file("res://assets/main_menu.tscn")
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Добавляем значение к текущему углу
		#var change_x = event.relative.y * MOUSE_SENSITIVITY
		#
		## Чтобы не делать "сальто", ограничиваем угол (примерно от -80 до 80 градусов)
		## 1.57 радиан — это примерно 90 градусов
		#rotation.x = clamp(rotation.x + change_x, deg_to_rad(-80), deg_to_rad(80))
		var new_rotation_x = camera_origin.rotation.x - (-event.relative.y * MOUSE_SENSITIVITY)
		
		# Ограничиваем наклон, чтобы не смотреть сквозь текстуры (примерно 80 градусов)
		camera_origin.rotation.x = clamp(new_rotation_x, deg_to_rad(0), deg_to_rad(25))
		
		
func _physics_process(delta: float) -> void:	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction := (visuals.global_basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	
	if direction:
		if Input.is_action_pressed("press_shift") and is_on_floor():
			velocity.x = direction.x * (SPEED + RUN)
			velocity.z = direction.z * (SPEED + RUN)
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Атака
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
		
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0:
		
		perform_attack()
	else:
		if anim_player.current_animation != "Attack/mixamo_com":
			update_animations(direction)

	move_and_slide()

func perform_attack() -> void:
	if attack_cooldown > 0:
		return
	current_anim = "Attack/mixamo_com"
	var anim_length = anim_player.get_animation(current_anim).length
	var playback_speed = 2
	attack_cooldown = anim_length / playback_speed
	anim_player.play(current_anim, 0.5, playback_speed)
	attack_sound.play()
	await get_tree().create_timer(0.6).timeout
	perform_raycast_attack()
	
	
func perform_raycast_attack() -> void:
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from + camera.global_transform.basis.z * -3.0   # 3 метра — нормальная дистанция удара
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	query.exclude = [self.get_rid()]
	
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is CharacterBody3D:
		var enemy = result.collider
		
		if enemy.has_method("take_damage"):
			enemy.take_damage(ATTACK_DAMAGE)
			damage_sound.play()          # звук удара игрока
		elif "health" in enemy:
			enemy.health -= ATTACK_DAMAGE
			if enemy.health <= 0:
				enemy.queue_free()

# В конец скрипта игрока
# --- В скрипте игрока ---

func take_damage(amount: int) -> void:
	# Уменьшаем здоровье через менеджер
	GameManager.update_health(-amount) 
	
	# Проигрываем звук (он у вас в @onready var damage_sound)
	if damage_sound:
		damage_sound.play()

func die() -> void:
	# Ваша логика смерти (перезагрузка сцены или экран смерти)
	get_tree().reload_current_scene()

func update_animations(direction: Vector3) -> void:
	var next_anim := "Idle/mixamo_com"

	if not is_on_floor():
		next_anim = "Jump/mixamo_com"
	elif direction != Vector3.ZERO:
		var local_dir := visuals.global_transform.basis * direction.normalized()

		var forward_dot = local_dir.z  
		var strafe_dot  = local_dir.x

		if forward_dot < -0.5:
			next_anim = "StepBack/mixamo_com"
		elif abs(forward_dot) < 0.3 and abs(strafe_dot) > 0.5:
			next_anim = "Run/mixamo_com"      # можно потом разделить на Left/Right
		else:
			next_anim = "Run/mixamo_com"

	if current_anim != next_anim:
		current_anim = next_anim
		if current_anim == "Jump/mixamo_com":
			anim_player.play(current_anim, 0.5, 1.5)
		else:
			anim_player.play(current_anim, 0.15)

#func _on_attack_animation_finished(anim_name: String) -> void:
	#if anim_name == "Attack/mixamo_com":
		## Теперь наносим урон
		#
		## Отключаем сигнал, чтобы он не срабатывал на других анимациях
		#if anim_player.animation_finished.is_connected(_on_attack_animation_finished):
			#anim_player.animation_finished.disconnect(_on_attack_animation_finished)
