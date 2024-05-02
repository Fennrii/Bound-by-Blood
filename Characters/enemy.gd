extends CharacterBody2D


@export var speed : float = 100.0
#const JUMP_VELOCITY = -400.0
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_ray : RayCast2D = $FloorRay
@onready var battle = preload("res://scenes/battle/battle.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation_locked : bool = false
var direction : int = 0
var floor_in_front : bool = true
var able_to_move : bool = true
var turn_timer : int = 0
var face_left : bool = true

var not_hit_player = true
var in_battle = false

func _ready():
	Events.battle_over.connect(unPause)
	Events.pause_overworld.connect(pause)

func _physics_process(delta):
	if in_battle:
		return
	# Add the gravity.
	if not is_on_floor_only():
		velocity.y += gravity * delta
		able_to_move = false
	else:
		able_to_move = true
		floor_check()
		turn_check()
		
	# Enemy Collision Detection
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider() == null:
			pass
		elif get_slide_collision(i).get_collider().has_method("jump"):
			player_hit()
			not_hit_player = false
			await get_tree().create_timer(0.1).timeout
		elif get_slide_collision(i).get_collider().has_method("open_chest"):
			scale = Vector2(scale.x * -1,scale.y)
			face_left = not face_left

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
	update_animation()
		

func unPause():
	in_battle = false

func pause():
	in_battle = true
	
# Checks to see if movement is viable
func floor_check():
	if floor_ray.is_colliding() == false or floor_ray.get_collision_normal().y == 0:
		floor_in_front = false
	else:
		floor_in_front = true
# Turns Enemy around if not able to move
func turn_check():
	if not floor_in_front and turn_timer <= 0:
		scale = Vector2(scale.x * -1,scale.y)
		face_left = not face_left
		floor_in_front = true
		#turn_timer += 3
	#elif turn_timer > 0:
		#turn_timer = turn_timer -1

func player_hit():
	if not_hit_player:
		var battleInst = battle.instantiate()
		var currentNode = get_tree().current_scene
		Events.pause_overworld.emit()
		currentNode.add_sibling(battleInst)
		await Events.battle_over
		queue_free()
	
func update_animation():
	if not animation_locked:
		if not is_on_floor():
			pass
		else:
			if direction != 0:
				animated_sprite.play("run")
			else:
				animated_sprite.play("idle")
				
		

func free_node_tree(tree):
	for child in tree.get_children():
		if child.get_children:
			free_node_tree(child)
		child.queue_free()
