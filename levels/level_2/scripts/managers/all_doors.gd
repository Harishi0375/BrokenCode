extends Area2D

@export var next_door_path : NodePath

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.just_teleported:
		return
	if next_door_path:
		var next_door = get_node(next_door_path)
		body.set_teleport_immunity()
		if next_door.has_node("SpawnPoint"):
			body.global_position = next_door.get_node("SpawnPoint").global_position
		else:
			body.global_position = next_door.global_position
