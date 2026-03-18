extends Node3D

var shake_amount := 0
var sensitivity := 0.5
var mousetstate := true

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		$CameraHolder.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		$CameraHolder.rotation.x = clamp($CameraHolder.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	if Input.is_action_just_pressed("ui_cancel"):
		pointer_state()

## mouse pointer function to toggle mouse visibility
func pointer_state() -> void:
	mousetstate = !mousetstate
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if (mousetstate == false) else Input.MOUSE_MODE_VISIBLE)
