extends RigidBody2D

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
var is_opened : bool = false
var random = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open_chest():
	if not is_opened:
		animated_sprite.play("default")
		is_opened = true
		if random.randi_range(1,100) > 80:
			return [1,random.randi_range(1,3)]
		else:
			return [0,random.randi_range(1,20)]
