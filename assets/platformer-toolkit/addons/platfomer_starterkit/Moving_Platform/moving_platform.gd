@tool
extends AnimatableBody3D

@onready var Path_manager : PathFollow3D = self.get_parent().get_child(0)
@onready var Path_Follower : RemoteTransform3D = self.get_parent().get_child(0).get_child(0)
@export_range(1, 50, 1) var Platform_speed: float ## Platform movement speed  
@export_range(1, 50, 1) var Platform_delay: float ## Platform delay time at each end pont
var tween

func _ready() -> void:
	if !Engine.is_editor_hint():
		tween = get_tree().create_tween()
		Path_Follower.remote_path = get_parent().get_child(1).get_path()
		
		tween.tween_property(Path_manager, "progress_ratio",1.0, Platform_speed).set_delay(Platform_delay)
		tween.tween_property(Path_manager, "progress_ratio",0.0, Platform_speed).set_delay(Platform_delay)
		tween.set_loops()
		set_process(false)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if !get_parent().is_class("Path3D"):
		return ["Parent node must be a moving platform path"]
	return [] 

func _exit_tree() -> void:
	if !Engine.is_editor_hint():
		tween.kill()
