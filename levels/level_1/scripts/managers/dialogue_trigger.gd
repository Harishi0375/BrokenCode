extends Area2D

@export var dialogue_lines: Array[String] = []

# When true, the trigger will only fire once and then queue_free itself
@export var one_shot: bool = true

func _ready() -> void:
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player entering
	if body.name == "player" or body.is_in_group("player"):
		# Find the Level2Dialogue UI in the scene tree
		var dialogue_ui = get_tree().get_first_node_in_group("level2_dialogue")
		if dialogue_ui:
			dialogue_ui.show_dialogue(dialogue_lines)
			
			if one_shot:
				# Wait for dialogue to finish if we want, or just delete ourselves immediately
				# We can connect to the signal to queue_free after the dialogue is done, or do it now.
				# Doing it now is safer so it doesn't re-trigger while dialogue is open.
				queue_free()
		else:
			print("Error: Level2Dialogue UI not found in group 'level2_dialogue'")
