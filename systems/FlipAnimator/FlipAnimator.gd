extends Node3D

signal flipCompleted

@export var cardNode:NodePath
@export var cardProxyNode:NodePath

@onready var card_rig: Node3D = $CardRig
@onready var card_proxy_rig: Node3D = $CardProxyRig

#Meshes
var cardMesh:MeshInstance3D
var cardProxyMesh:MeshInstance3D
var originalCardParent:Node3D
var originalCardProxyParent:Node3D

var isAnimating := false

func _ready() -> void:
	cardMesh = get_node(cardNode)
	originalCardParent = cardMesh.get_parent()
	
	cardProxyMesh = get_node(cardProxyNode)
	originalCardProxyParent = cardProxyMesh.get_parent()

func doAFlip(dir:String):
	isAnimating = true
	# Add card to card Rig
	# Add cardProxy to proxy Rig
	# Show proxy
	# hide card1
	# add card1 to pivot
	# Rotate and move pivot
	# dispose proxy
	# remove card from pivot
	card_rig.rotation_degrees = Vector3(0,0,0)
	
	originalCardParent.remove_child(cardMesh)
	card_rig.add_child(cardMesh)
	
	originalCardProxyParent.remove_child(cardProxyMesh)
	card_proxy_rig.add_child(cardProxyMesh)
	
	cardMesh.visible = false
	cardProxyMesh.visible = true
	cardProxyMesh.global_position = cardMesh.global_position
	cardProxyMesh.global_rotation = cardMesh.global_rotation
	
	# Note: scaling is ignored
	
	var finalRot = card_rig.rotation_degrees
	finalRot.x -= 180
	finalRot.x = round(finalRot.x / 90.0) * 90.0
	
	var tween = create_tween()
	tween.tween_property(card_rig, "rotation_degrees", finalRot, 2)\
			.set_trans(Tween.TRANS_LINEAR)\
			.set_ease(Tween.EASE_OUT)
	await tween.finished

	# TODO: Uncomment: 
	cardProxyMesh.visible = false
	cardMesh.visible = true
	card_rig.remove_child(cardMesh)
	originalCardParent.add_child(cardMesh)
	card_proxy_rig.remove_child(cardProxyMesh)
	originalCardProxyParent.add_child(cardProxyMesh)
	
	emit_signal("flipCompleted")
	isAnimating = false
