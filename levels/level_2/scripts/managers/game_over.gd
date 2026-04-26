extends CanvasLayer

func _ready():
	print("Game Over screen ready")
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	if has_node("AnimationPlayer") and $AnimationPlayer.has_animation("fade_in"):
		$AnimationPlayer.play("fade_in")

func _on_restart_pressed():
	get_tree().paused = false # Unpause
	get_tree().reload_current_scene()
