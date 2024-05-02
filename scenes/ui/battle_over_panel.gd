class_name BattleOverPanel
extends Panel

enum Type {WIN, LOSE}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton
@onready var restart_button: Button = %RestartButton


func _ready() -> void:
	continue_button.pressed.connect(continue_game)
	restart_button.pressed.connect(restart_game)
	Events.battle_over_screen_requested.connect(show_screen)


func show_screen(text: String, type: Type) -> void:
	label.text = text
	continue_button.visible = type == Type.WIN
	restart_button.visible = type == Type.LOSE
	show()
	get_tree().paused = true

func continue_game():
	Events.battle_over.emit()
	hide()
	free_node_tree(get_tree().root.get_node("/root/Battle"))
	get_tree().paused = false

func restart_game():
	hide()
	free_node_tree(get_tree().root.get_node("/root/Battle"))
	print(get_tree().current_scene)
	get_tree().reload_current_scene()
	get_tree().paused = false
	
func free_node_tree(tree):
	for child in tree.get_children():
		if child.get_children:
			free_node_tree(child)
		child.queue_free()
