extends Node2D

# 1. LINKING THE BUTTONS
@onready var play_btn = $PlayButton
@onready var exit_btn = $ExitButton
@onready var title_label = $TitleLabel
@onready var no_escape_bubble = $NoEscapeBubble

var exit_tries = 0

# 2. POSITION & SCALE SETTINGS
const CENTER_X = 576   
const CENTER_Y = 280   
const GAP = 60         

# Your specific custom scales
const BASE_SCALE = Vector2(2.148, 1.467)
const HOVER_SCALE = Vector2(2.36, 1.61) 

func _ready():
	# Title pulsing animation to be eye-catching!
	var title_tween = create_tween().set_loops()
	title_tween.tween_property(title_label, "scale", Vector2(1.08, 1.08), 1.2).set_trans(Tween.TRANS_SINE)
	title_tween.tween_property(title_label, "scale", Vector2(0.95, 0.95), 1.2).set_trans(Tween.TRANS_SINE)
	
	# Apply scale and center pivots
	play_btn.scale = BASE_SCALE
	exit_btn.scale = BASE_SCALE
	update_pivots()
	
	# Calculate landing spots
	var play_pos = Vector2(CENTER_X, CENTER_Y - GAP)
	var exit_pos = Vector2(CENTER_X, CENTER_Y + GAP)
	
	# --- THE PINCER START ---
	play_btn.position = Vector2(-800, play_pos.y)  # From Left
	exit_btn.position = Vector2(1500, exit_pos.y) # From Right
	
	# Small delay before they fly in
	get_tree().create_timer(0.4).timeout.connect(animate_intro)

func animate_intro():
	var play_pos = Vector2(CENTER_X, CENTER_Y - GAP)
	var exit_pos = Vector2(CENTER_X, CENTER_Y + GAP)
	
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Fly to center
	tween.tween_property(play_btn, "position", play_pos, 0.8)
	tween.tween_property(exit_btn, "position", exit_pos, 0.8)

func update_pivots():
	# Crucial for scaling from the center
	play_btn.pivot_offset = play_btn.size / 2
	exit_btn.pivot_offset = exit_btn.size / 2

# --- SIGNALS FOR PLAY BUTTON ---

func _on_play_button_mouse_entered():
	update_pivots()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(play_btn, "scale", HOVER_SCALE, 0.1)
	tween.tween_property(play_btn, "modulate", Color(1.3, 1.3, 1.3), 0.1)

func _on_play_button_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(play_btn, "scale", BASE_SCALE, 0.1)
	tween.tween_property(play_btn, "modulate", Color(1, 1, 1), 0.1)

func _on_play_button_pressed():
	# Disable buttons to prevent double-clicks
	play_btn.disabled = true
	exit_btn.disabled = true
	
	# The "Stab" Animation
	var tween = create_tween()
	# TRANS_BACK + EASE_IN makes it pull back slightly then lunge!
	tween.tween_property(play_btn, "position:x", 1600, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Wait for animation to finish then swap scene
	tween.finished.connect(_go_to_story)

func _go_to_story():
	# Make sure you have a scene saved at this exact path!
	get_tree().change_scene_to_file("res://story_scene.tscn")

# --- SIGNALS FOR EXIT BUTTON ---

func _on_exit_button_mouse_entered():
	update_pivots()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(exit_btn, "scale", HOVER_SCALE, 0.1)
	tween.tween_property(exit_btn, "modulate", Color(1.3, 1.3, 1.3), 0.1)
	
	# Escape logic! Shoot straight up so it rests physically *above* the title at the top of the screen
	var escape_y = -20 if exit_btn.position.y > 100 else (CENTER_Y + GAP)
	tween.tween_property(exit_btn, "position:y", escape_y, 0.15).set_trans(Tween.TRANS_EXPO)
	
	# Keep X position centered just in case it was modified before
	tween.tween_property(exit_btn, "position:x", CENTER_X, 0.15)

func _on_exit_button_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(exit_btn, "scale", BASE_SCALE, 0.1)
	tween.tween_property(exit_btn, "modulate", Color(1, 1, 1), 0.1)
	# We intentionally don't reset position here so it stays far away!

func _on_exit_button_pressed():
	exit_tries += 1
	if exit_tries >= 3:
		no_escape_bubble.visible = true
		
	# Do not quit! Escape is impossible.
