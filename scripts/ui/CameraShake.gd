extends Camera2D

var shake_duration = 0.0
var shake_intensity = 0.0
var original_offset = Vector2.ZERO

func _ready():
	original_offset = offset

func _process(delta):
	if shake_duration > 0:
		shake_duration -= delta
		offset = original_offset + Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
	else:
		offset = original_offset

func shake(duration: float, intensity: float):
	shake_duration = duration
	shake_intensity = intensity
