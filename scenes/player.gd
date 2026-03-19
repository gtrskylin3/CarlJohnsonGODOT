extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6
const MOUSE_SENSITIVITY = 0.003

@onready var anim_player: AnimationPlayer = $Visuals/CarlJohnson/AnimationPlayer2
@onready var visuals: Node3D = $Visuals
@onready var camera_origin: Node3D = $CamOrigin
@onready var camera: Camera3D = $CamOrigin/Camera3D

var current_anim: String = ""
func _ready() -> void:
	# ВКЛЮЧАЕМ РЕЖИМ ЗАХВАТА: мышь исчезает и не упирается в края экрана
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Добавляем значение к текущему углу
		#var change_x = event.relative.y * MOUSE_SENSITIVITY
		#
		## Чтобы не делать "сальто", ограничиваем угол (примерно от -80 до 80 градусов)
		## 1.57 радиан — это примерно 90 градусов
		#rotation.x = clamp(rotation.x + change_x, deg_to_rad(-80), deg_to_rad(80))
		var new_rotation_x = camera_origin.rotation.x - event.relative.y * MOUSE_SENSITIVITY
		
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
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Атака
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if current_anim != "Attack/mixamo_com":
			current_anim = "Attack/mixamo_com"
			anim_player.play(current_anim, 0.1)
	else:
		if anim_player.current_animation != "Attack/mixamo_com":
			update_animations(direction)

	move_and_slide()


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
