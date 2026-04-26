extends Area2D

var triggered : bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if body.is_in_group("player"):
		triggered = true
		get_tree().paused = true
		var victory_scene = load("res://scenes/victory.tscn")
		if victory_scene:
			var vic = victory_scene.instantiate()
			vic.process_mode = Node.PROCESS_MODE_ALWAYS
			get_tree().root.add_child(vic)
		else:
			print("Victory scene not found!")
