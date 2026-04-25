extends Node2D

@onready var camera = $Camera2D
@onready var story_label = $Label

func _ready():
	# Hide text immediately so we only see the walk
	story_label.visible = false
	start_walking_to_paper()

func start_walking_to_paper():
	var walk_duration = 2.8
	var steps = 6
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "zoom", Vector2(2.2, 2.2), walk_duration).set_trans(Tween.TRANS_SINE)
	
	for i in range(steps):
		var step_tween = create_tween()
		step_tween.tween_property(camera, "offset:y", -15, walk_duration/(steps*2))
		step_tween.tween_property(camera, "offset:y", 0, walk_duration/(steps*2))

	# THE MERGE: Wait for the walk to finish, then show text
	await tween.finished
	show_story_text()

func show_story_text():
	story_label.visible = true
	# Vibe coding tip: add a little fade-in for the text
	story_label.modulate.a = 0
	create_tween().tween_property(story_label, "modulate:a", 1.0, 1.0)
