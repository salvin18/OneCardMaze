extends Node3D

#TODO: Use export variables instead
@onready var cardMesh: MeshInstance3D = $Card/Card1Mesh
@onready var cardMeshProxy: MeshInstance3D = $Card/Card1MeshProxy
@onready var flip_animation: Node3D = $FlipAnimation

@onready var maze_pathFront: MazePath = $MazePathFront
@onready var maze_pathBack: MazePath = $MazePathBack
@onready var player: CharacterBody3D = $Player

@onready var remote_cam_overview: RemoteTransform3D = $RemoteCamOverview
@onready var remote_cam_follow: RemoteTransform3D = $RemoteCamFollow

@onready var camera_3d: Camera3D = $Camera3D
@onready var cam_v_pos: Marker3D = $CamVPos
@onready var cam_h_pos: Marker3D = $CamHPos

var isAnimating = false
var currentMazePath:MazePath

func _ready() -> void:
	cardMeshProxy.visible = false
	cardMeshProxy.rotation = Vector3.ZERO
	
	maze_pathBack.position.x = 0 # moves it back to position
	currentMazePath = maze_pathFront
	#currentMazePath.init("StartNode") #Initialize # TODO: ENABLE
	currentMazePath.init("NextScreen1") #TODO: REMOVE

	setCamFollow(remote_cam_overview)

func _on_cam_overview_btn_pressed() -> void:
	setCamFollow(remote_cam_overview)

func _on_cam_follow_btn_pressed() -> void:
	setCamFollow(remote_cam_follow)

func _process(delta: float) -> void:
	remote_cam_follow.position.x = player.position.x
	remote_cam_follow.position.z = player.position.z

func setCamFollow(remoteNode:RemoteTransform3D) -> void:
	# Reset all:
	remote_cam_overview.remote_path = %DUMMY.get_path()
	remote_cam_follow.remote_path = %DUMMY.get_path()
	remoteNode.remote_path = camera_3d.get_path()

func _on_maze_path_do_a_flip(dir: Variant, foriegnNode: Variant, extra_arg_0: String, extra_arg_1: String) -> void:
	flip_animation.doFlip(dir, cardMesh, cardMeshProxy)
	await flip_animation.flipFinished
	flipFinished()

func flipFinished() -> void:
	print("Flip finished")

func animatePlayer(node:Node3D) -> void:
	if isAnimating:
		return

	isAnimating = true
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", node.global_position, 0.3)\
			.set_trans(Tween.TRANS_SPRING)\
			.set_ease(Tween.EASE_OUT)

	await tween.finished
	isAnimating = false

func _on_maze_path_current_node_changed() -> void:
	animatePlayer(currentMazePath.getCurrentNode())

func _on_move_ui_move_top() -> void:
	if isAnimating:
		return
	currentMazePath.attempMove("UP")

func _on_move_ui_move_down() -> void:
	if isAnimating:
		return
	currentMazePath.attempMove("DOWN")

func _on_move_ui_move_left() -> void:
	if isAnimating:
		return
	currentMazePath.attempMove("LEFT")

func _on_move_ui_move_right() -> void:
	if isAnimating:
		return
	currentMazePath.attempMove("RIGHT")

func _on_move_ui_rotate_left() -> void:
	if currentMazePath.canRotate():
		rotateCamY(-90)

func _on_move_ui_rotate_right() -> void:
	if currentMazePath.canRotate():
		rotateCamY(90)

func rotateCamY(val:float) -> void:
	if isAnimating:
		return
	
	isAnimating = true
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var finalRot:Vector3 = Vector3(camera_3d.rotation_degrees.x, \
		int(camera_3d.rotation_degrees.y) + int(val), \
		camera_3d.rotation_degrees.z)
	# Snaps to nearest 90
	finalRot.y = round(finalRot.y / 90.0) * 90.0
	
	var finalCamGlobalPos:Vector3
	if ([-90, 90, 270, -270].has(int(finalRot.y))):
		finalCamGlobalPos = cam_h_pos.global_position
	else:
		finalCamGlobalPos = cam_v_pos.global_position

	tween.tween_property(camera_3d, "rotation_degrees", finalRot, 0.5)\
			.set_trans(Tween.TRANS_BOUNCE)\
			.set_ease(Tween.EASE_OUT)
			
	tween2.tween_property(remote_cam_overview, "global_position", finalCamGlobalPos, 0.8)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	await tween2.finished
	# No longer needed.
	#camera_3d.rotation_degrees.y = round(camera_3d.rotation_degrees.y / 90.0) * 90.0

	# change 360 to 0 after animation
	if camera_3d.rotation_degrees.y >= 360:
		camera_3d.rotation_degrees.y = 360-camera_3d.rotation_degrees.y
	elif camera_3d.rotation_degrees.y < 0:
		camera_3d.rotation_degrees.y = 360+camera_3d.rotation_degrees.y
	
	
	isAnimating = false
