extends CharacterBody2D


@export var max_speed : float = 200.0
@export var speed_mult : float = 10.0
@export var jump_velocity : float = -200
@export var double_jump_velocity : float = -200

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false
var prev_wall_normal : Vector2 = Vector2.ZERO
var direction_lock : bool = false
var regex = RegEx.new()
static var Inventory: Array = [[],[]]


func _physics_process(delta):
	
	regex.compile("\\d+$")
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else:
		has_double_jumped = false
		direction_lock = false
		prev_wall_normal = Vector2.ZERO
		
		if was_in_air:
			land()
			was_in_air = false
	
# Collision logic
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider().name.contains("Chest"):
			add_inv_item(get_slide_collision(i).get_collider())
		elif get_slide_collision(i).get_collider().name.contains("Enemy"):
			enemy_hit(get_slide_collision(i).get_collider())
		

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
#			# Normal Jump
			jump()
		elif is_on_wall():
			wall_jump()
		elif not has_double_jumped:
			# Double Jump
			double_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if direction.x != 0 && animated_sprite.animation != "jump_end":
		velocity.x = max(min(direction.x * speed_mult + velocity.x,max_speed),-max_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, max_speed)
	
	move_and_slide()
	update_facing_direction()
	update_animation()

func update_animation():
	if not animation_locked:
		if not is_on_floor():
			animated_sprite.play("jump_loop")
		else:
			if direction.x != 0:
				animated_sprite.play("run")
			else:
				animated_sprite.play("idle")
func update_facing_direction():
	if not direction_lock:
		if direction.x > 0:
			animated_sprite.flip_h = false
		elif direction.x < 0:
			animated_sprite.flip_h = true
		
func jump():
	velocity.y = jump_velocity
	animated_sprite.play("jump_start")
	animation_locked = true
	
func double_jump():
	velocity.y = double_jump_velocity;
	animated_sprite.play("jump_double")
	animation_locked = true
	has_double_jumped = true
	prev_wall_normal = Vector2.ZERO
	direction_lock = false
	
func wall_jump():
	
	var wall_velocity = get_wall_normal()
	if wall_velocity != prev_wall_normal:
		direction_lock = false
		velocity.y = double_jump_velocity
		velocity.x = wall_velocity.x * max_speed
		direction.x = velocity.x
		update_facing_direction()
		direction_lock = true
		prev_wall_normal = wall_velocity
	
	
func land():
	animated_sprite.play("jump_end")
	animation_locked = true

func _on_animated_sprite_2d_animation_finished():
	if(["jump_end","jump_start","jump_double"].has(animated_sprite.animation)):
		animation_locked = false

# can randomly be assigned either 1 of 20 cards or 1 of 3 items/powerups
func add_inv_item(object : Object):	
	var newItem = object.open_chest()
	if newItem != null:
		Inventory[newItem[0]].append(newItem[1])
		if newItem[0]==0:
			find_child("HUD").show_message("You Found a Card!")
		else:
			find_child("HUD").show_message("You Found an Item!")
	
# TODO: Add connecter to battle scene
func enemy_hit(object : Object):
	print("Enemy on-hit")
	object.free()
	
