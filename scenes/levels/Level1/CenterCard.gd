extends Node3D

signal showPreview(flipDirection:String)
signal hidePreview(flipDirection:String)
signal doFlip(flipDirection:String)
signal doCardRotate()

signal showText(textId:String)
signal hideText()
signal doorPassageNotAllowed 

@onready var currentComponents = $FrontComponents


func _ready() -> void:
	$DUMMY.visible = false
	$DUMMY.queue_free()
	$BackComponents.position = Vector3.ZERO
	$BackComponents.rotation_degrees.z = 180
	
	#Setup all automatic signal listerns:
	addAllDoorListeners($BackComponents)
	addAllDoorListeners($FrontComponents)
	setComponentsEnabled(currentComponents, true)


func addAllDoorListeners(node:Node3D):
	for child in node.get_children():
		if child.is_in_group("Door"):
			child.doorPassageNotAllowed.connect(_on_door_passage_not_allowed)

func setComponentsEnabled(node:Node3D, val: bool):
	var hidePos = Vector3(0,-10, 0) # down below
	$FrontComponents.global_position = hidePos
	$BackComponents.global_position = hidePos
	if val:
		node.position = Vector3.ZERO
	else:
		node.global_position = hidePos

func setAllHintsMonitoring(node:Node3D, val: bool):
	for child in node.get_children():
		if child is Area3D and child.is_in_group("HintText"):
			(child as Area3D).monitoring = val

func setAllColliderEnabled(node:Node3D, val: bool):
	for child in node.get_children():
		if child is StaticBody3D:
			for colliders in child.get_children():
				if colliders is CollisionPolygon3D:
					colliders.disabled = !val

func refreshAllDoors():
	for child in currentComponents.get_children():
		if child.is_in_group("Door"):
			var door:Node3D = child
			# Door is opened only if its facing right direction
			if Global.isRoundedEqual(door.global_rotation_degrees, Vector3(0,0,0)):
				door.doorOpened = true
			else:
				door.doorOpened = false
	pass

func changeToFront(offsetAngle: Vector3) -> void:
	currentComponents = $FrontComponents
	setComponentsEnabled($BackComponents, false)
	setComponentsEnabled($FrontComponents, true)


func changeToBack(offsetAngle: Vector3) -> void:
	currentComponents = $BackComponents
	setComponentsEnabled($FrontComponents, false)
	setComponentsEnabled($BackComponents, true)

func setFlipDetectorsEnabled(val:bool) -> void:
	# Enable all FlipDetectors
	#for child in currentComponents.get_children():
		#if child.is_in_group("FlipDetectorGrp"):
			#child.enabled = val
	pass # METHOD IS DEPRECATED

# Bubble up the events:
func _on_flip_detector_do_flip(flipDirection:String) -> void:
	setComponentsEnabled(currentComponents, false)
	emit_signal("doFlip", flipDirection)

func _on_flip_detector_hide_preview(flipDirection:String) -> void:
	emit_signal("hidePreview", flipDirection)

func _on_flip_detector_show_preview(flipDirection:String) -> void:
	emit_signal("showPreview", flipDirection)

func _on_area_text_body_entered(body: Node3D, textId:String) -> void:
	if body.is_in_group("Player"):
		emit_signal("showText", textId)

func _on_area_text_body_exited(body: Node3D) -> void:
	emit_signal("hideText")

func _on_rotater_do_card_rotate() -> void:
	emit_signal("doCardRotate")

func _on_door_passage_not_allowed() -> void:
	emit_signal("doorPassageNotAllowed")
	#emit_signal("showText", "Door Not allowed")
