extends RigidBody2D

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
var is_opened : bool = false
var random = RandomNumberGenerator.new()

func open_chest():
	if not is_opened:
		animated_sprite.play("default")
		is_opened = true
		if random.randi_range(1,100) > 80: # 80% chance to give a card rather than a item
			return [1,random.randi_range(1,3)]
		else:
			return [0,random.randi_range(1,20)]
