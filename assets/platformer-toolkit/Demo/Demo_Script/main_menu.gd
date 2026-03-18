extends Node

@export var Level_1: PackedScene
@export var Level_2: PackedScene

@onready var levels = get_tree().get_nodes_in_group("Level")
@onready var Level_Data = $"/root/SaveSystem".get_setting("GAME_LEVELS","GAME_UNLOCKED_LEVEL")

func _ready() -> void:
	Display(true)
	level_Data_Update()

func level_Data_Update() -> void:
	Level_Data += 2
	for i in range(Level_Data,levels.size()):
		levels[i].disabled = true

func _on_start_pressed() -> void:
	Display(false)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	Display(true)

func Display(a)-> void:
	$Hud/MarginContainer/main.visible = a
	$Hud/MarginContainer/levelSelect.visible = !a


func _on_level_1_pressed() -> void:
	Switch(Level_1)

func _on_level_2_pressed() -> void:
	Switch(Level_2)

func Switch(a)-> void:
	get_tree().call_deferred("change_scene_to_packed", a)
