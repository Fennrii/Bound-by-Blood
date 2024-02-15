extends MarginContainer

#Delared member variables
@onready var CardDatabase = preload("res://Assets/Cards/CardsDatabase.gd").new
var Cardname = 'Footman'
@onready var CardInfo = CardDatabase.Data[CardDatabase.get(Cardname)]
@onready var CardImg = str("res://Assets/Cards/",CardInfo[0],"/",Cardname,".png")

# Called when the node enters the scene tree for the first time.
func _ready():
	print(CardInfo)
	var CardSize = size
	$Border.scale *= CardSize/$Border.texture.get_size()
	$Card.texture = load(CardImg)
	$Card.scale *= CardSize/$Card.texture.get_size()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
