extends CharacterBody2D


@export var speed : float = 0
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
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

func unPause():
	in_battle = false

func pause():
	in_battle = true

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
	if not_hit_player:
		not_hit_player = !not_hit_player
		var battleInst = battle.instantiate()
		var currentNode = get_tree().current_scene
		Events.pause_overworld.emit()
		currentNode.add_sibling(battleInst)
		await Events.battle_over
		for i in get_tree().root.get_node("/root/Level").get_children():
			if i.has_method("floor_check") or i.has_method("open_chest") or i.has_method("jump"):
				i.queue_free()
		get_tree().root.get_node("/root/Level").make_maze()
		get_tree().root.get_node("/root/Level").find_child("Camera2D2").find_child("HUD").show_message("Level Complete!")
		queue_free()
