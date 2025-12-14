extends Node3D

signal showPreview(flipDirection:String)
signal hidePreview(flipDirection:String)
signal doFlip(flipDirection:String)

# caller should call enable on all kids
# TODO: enabled is deprecated !!
var enabled := false
var isShowing := false

func _ready() -> void:
	$DUMMY.visible = false
	$DUMMY.queue_free()
	
	# NEW APPROACH
	enabled = true
	
	pass

func _on_do_flip_body_entered(body: Node3D) -> void:
	if !enabled or !body.is_in_group("Player"):
		return

	#Disable self, owner has to renabled
	#enabled = false
	if $RayCast3D.is_colliding():
		var collider:Node3D = $RayCast3D.get_collider()
		if collider.is_in_group("DetectionArea"):
			var colliderName = $RayCast3D.get_collider().name
			var dir = colliderName.split("_")[1]
			emit_signal("doFlip", dir)


func _on_show_preview_body_entered(body: Node3D) -> void:
	if !enabled or !body.is_in_group("Player"):
		return
	isShowing = true
	
	if $RayCast3D.is_colliding():
		var collider:Node3D = $RayCast3D.get_collider()
		if collider.is_in_group("DetectionArea"):
			var colliderName = $RayCast3D.get_collider().name
			var dir = colliderName.split("_")[1]
			emit_signal("showPreview", dir)

func _on_hide_preview_body_exited(body: Node3D) -> void:
	if !enabled or !isShowing or !body.is_in_group("Player"):
		return
	isShowing = false
	
	if $RayCast3D.is_colliding():
		var collider:Node3D = $RayCast3D.get_collider()
		if collider.is_in_group("DetectionArea"):
			var colliderName = $RayCast3D.get_collider().name
			var dir = colliderName.split("_")[1]
			emit_signal("hidePreview", dir)
