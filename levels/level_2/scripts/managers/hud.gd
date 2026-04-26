extends CanvasLayer

@onready var hearts_container = $Control/MarginContainer/HeartsContainer
@onready var hearts = [
	$Control/MarginContainer/HeartsContainer/Heart1,
	$Control/MarginContainer/HeartsContainer/Heart2,
	$Control/MarginContainer/HeartsContainer/Heart3,
	$Control/MarginContainer/HeartsContainer/Heart4,
	$Control/MarginContainer/HeartsContainer/Heart5
]

func _ready():
	var tex = load("res://assets/sprites/ui/heart.png")
	print("HUD: Manual texture load result: ", tex)
	for i in range(hearts.size()):
		if hearts[i] and tex:
			hearts[i].texture = tex
	print("HUD Ready. Hearts nodes: ", hearts)
	for i in range(hearts.size()):
		if hearts[i]:
			print("Heart ", i, " visible: ", hearts[i].visible, " size: ", hearts[i].size, " texture: ", hearts[i].texture if hearts[i] is TextureRect else "N/A")
		else:
			print("Heart ", i, " IS NULL!")

func update_hearts(new_lives: int):
	print("HUD: Updating hearts to ", new_lives)
	if not is_inside_tree(): return
	for i in range(hearts.size()):
		if hearts[i]:
			if i < new_lives:
				hearts[i].modulate.a = 1.0
				hearts[i].visible = true
			else:
				hearts[i].modulate.a = 0.2
			print("Heart ", i, " a: ", hearts[i].modulate.a, " visible: ", hearts[i].visible)

func update_health(health: int, max_health: int):
	# Level 2 uses hearts not a health bar, leave empty
	pass

func update_lives(lives: int):
	update_hearts(lives)

func show_death_screen(is_game_over: bool):
	# Handled by game_over.gd separately
	
	pass
	
	
func show_victory_screen():
	var victory_scene = load("res://levels/level_2/scenes/entities/victory.tscn")
	if victory_scene == null:
		print("ERROR: victory.tscn not found!")
		return
	var victory = victory_scene.instantiate()
	get_tree().current_scene.add_child(victory)
