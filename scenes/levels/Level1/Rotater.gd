extends Node3D

signal doCardRotate()

var isPassedThroughInner:=false
var isEnabled := true
func _on_rotater_area_body_entered(body: Node3D) -> void:
	#if body.is_in_group("Player"):
		#var direction := (body.global_position - global_position).normalized()
		#direction.y = 0
		#body.global_position += direction * 0.25
		#emit_signal("doCardRotate")
		pass


func _on_outer_area_body_entered(body: Node3D) -> void:
	pass


func _on_outer_area_body_exited(body: Node3D) -> void:
	if !body.is_in_group("Player"):
		return
	
	isEnabled = true
	if isPassedThroughInner:
		isPassedThroughInner = false
		emit_signal("doCardRotate")


func _on_inner_area_body_exited(body: Node3D) -> void:
	if !body.is_in_group("Player"):
		return
	isPassedThroughInner = true
