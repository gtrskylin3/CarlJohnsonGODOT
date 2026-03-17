extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Ссылки на узлы
@onready var anim_player: AnimationPlayer = $Visuals/CarlJohnson/AnimationPlayer2
@onready var visuals: Node3D = $Visuals

var current_anim: String = ""

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, -input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_anim = "Attack/mixamo_com"
		anim_player.play(current_anim, 0.1)
	
	# Вызываем обновление анимаций бега/айдла только если НЕ играем атаку
	if anim_player.current_animation != "Attack/mixamo_com":
			update_animations(direction)
	
	move_and_slide()

func update_animations(direction: Vector3) -> void:
	var next_anim = ""
	if not is_on_floor():
		next_anim = "Jump/mixamo_com"
	elif direction != Vector3.ZERO:
		next_anim = "Run/mixamo_com"
	else:
		next_anim = 'Idle/mixamo_com'
		
	if current_anim != next_anim:
		current_anim = next_anim
		anim_player.play(current_anim, 0.2)
