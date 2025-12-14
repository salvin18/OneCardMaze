extends GridContainer

signal moveLeft
signal moveRight
signal moveTop
signal moveDown
signal rotateLeft
signal rotateRight

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("moveLeft"):
		emitSignalForButton("moveLeft")
	elif Input.is_action_pressed("moveRight"):
		emitSignalForButton("moveRight")
	elif Input.is_action_pressed("moveTop"):
		emitSignalForButton("moveTop")
	elif Input.is_action_pressed("moveDown"):
		emitSignalForButton("moveDown")
	elif Input.is_action_pressed("rotateLeft"):
		emitSignalForButton("rotateLeft")
	elif Input.is_action_pressed("rotateRight"):
		emitSignalForButton("rotateRight")

func emitSignalForButton(signalName:String) -> void:
	emit_signal(signalName)
