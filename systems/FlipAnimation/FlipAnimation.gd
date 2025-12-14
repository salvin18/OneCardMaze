extends Node3D
@onready var anim: AnimationPlayer = $Anim
@onready var card_proxy_parent: Node3D = $CardsRig/CardProxyParent
@onready var card_parent: Node3D = $CardsRig/CardNew/CardParent

signal flipFinished

func doFlip(dir:String, cardMesh:Node3D, cardMeshProxy:Node3D) -> void:
	var owner1 = cardMesh.get_parent()
	var owner2 = cardMeshProxy.get_parent()
	var originalCardRot = cardMesh.global_rotation
	
	owner1.remove_child(cardMesh)
	owner2.remove_child(cardMeshProxy)
	card_proxy_parent.add_child(cardMeshProxy)
	card_parent.add_child(cardMesh)
	
	cardMesh.position = Vector3.ZERO
	cardMeshProxy.position = Vector3.ZERO
	cardMeshProxy.rotation = originalCardRot
	cardMeshProxy.visible = true
	
	anim.play(dir)
	await anim.animation_finished
	var flippedRot = cardMesh.global_rotation
	
	card_proxy_parent.remove_child(cardMeshProxy)
	card_parent.remove_child(cardMesh)
	owner1.add_child(cardMesh)
	owner2.add_child(cardMeshProxy)
	cardMesh.global_rotation = flippedRot
	cardMeshProxy.visible = false
	
	emit_signal("flipFinished")
	
