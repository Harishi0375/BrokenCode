extends Area2D

func _ready():
	# Connect signal if not already connected in editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check for "player" group or name
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		print("Stairs: Victory reached!")
		if GameManager.has_method("on_victory"):
			GameManager.on_victory()
