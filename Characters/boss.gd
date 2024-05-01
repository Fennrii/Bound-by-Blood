extends CharacterBody2D


@export var speed : float = 0
#const JUMP_VELOCITY = -400.0
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation_locked : bool = false
var direction : int = 0
var floor_in_front : bool = true
var able_to_move : bool = true
var turn_timer : int = 0
var face_left : bool = true



func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor_only():
		velocity.y += gravity * delta
		able_to_move = false
	else:
		able_to_move = true
	# Enemy Collision Detection
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider() == null:
			pass
		elif get_slide_collision(i).get_collider().name.contains("Player"):
			player_hit()

	# Do Enemy Movement
	direction = -scale.x
	if able_to_move:
		if direction != 0 and face_left:
			velocity.x = direction * speed
		elif direction != 0 and not face_left:
			velocity.x = -direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	
# Checks to see if movement is viable


func player_hit():
	print("Boss on-hit")
	for i in get_tree().root.get_children()[0].get_children():
		if i.has_method("floor_check") or i.has_method("open_chest") or i.has_method("jump"):
			i.queue_free()
	get_tree().root.get_children()[0].make_maze()
	get_tree().root.get_children()[0].find_child("Camera2D2").find_child("HUD").show_message("Level Complete!")
	queue_free()
