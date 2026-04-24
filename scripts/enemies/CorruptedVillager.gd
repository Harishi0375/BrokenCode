extends BaseEnemy
class_name CorruptedVillager

# Node reference for Navigation
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D

func _ready():
	super._ready() # Call parent _ready
	
	# Create NavigationAgent2D dynamically if it doesn't exist (useful for pure script setup)
	if nav_agent == null:
		nav_agent = NavigationAgent2D.new()
		add_child(nav_agent)

func _physics_process(delta):
	if player == null:
		return
	
	# Simple chasing logic using NavigationAgent2D
	nav_agent.target_position = player.global_position
	
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		velocity = direction * speed
	
	move_and_slide()
