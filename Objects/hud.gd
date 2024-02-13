extends CanvasLayer


func show_message(text: String):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()
	
	

func _on_message_timer_timeout():
	$MessageLabel.hide()
