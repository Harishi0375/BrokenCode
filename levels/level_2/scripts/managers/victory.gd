extends CanvasLayer

func _ready():
	$AnimationPlayer.play("victory_anim")
	await get_tree().create_timer(4.0).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
