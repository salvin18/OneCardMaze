extends StaticBody3D

signal doorPassageNotAllowed 

# Expects parent to set collision shape based on design

var doorOpened:= false:
	set(val):
		doorOpened = val
		setCollisionsEnabled() 

func _ready() -> void:
	$DUMMY.queue_free()

func setCollisionsEnabled():
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = doorOpened

func _on_rejection_check_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !doorOpened:
		emit_signal("doorPassageNotAllowed")
