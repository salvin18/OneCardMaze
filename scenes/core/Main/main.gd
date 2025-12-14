extends Node

@onready var ui: MarginContainer = $UI

func _ready() -> void:
	# Wont work with signals, dropping the idea
	#changeUI(load("res://scenes/UI/MoveUI/MoveUI.tscn").instantiate())
	pass
