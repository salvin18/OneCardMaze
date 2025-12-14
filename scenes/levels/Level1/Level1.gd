extends Node3D
@onready var player: CharacterBody3D = $CardRotater/Player
@onready var card_rotater: Node3D = $CardRotater
@onready var center_card: Node3D = $CardRotater/CenterCardRig/CardFacingDir/CenterCard
@onready var center_card_dir: Node3D = $CardRotater/CenterCardRig/CardFacingDir
@onready var proxy_rig: Node3D = $CardRotater/CenterCardRig/ProxyRig
@onready var proxy_facing_dir: Node3D = $CardRotater/CenterCardRig/ProxyRig/ProxyFacingDir

@onready var hint_text_container: PanelContainer = $LevelUI/VBoxContainer/HintTextContainer
@onready var hint_text_label: RichTextLabel = $LevelUI/VBoxContainer/HintTextContainer/HintTextLabel


@onready var pivotConfig := {
	"TOP": {
		"cardFacingDirNode" : $CardRotater/CardTopPivot/CardFacingDir,
		"cardPivotNode" : $CardRotater/CardTopPivot,
		"animationName" : "FlipTop",
		"flipOffsetAngle" : Vector3(180,0,0),
		"playerMoveOffset" : Vector3(0,0,5)
	},
	"RIGHT": {
		"cardFacingDirNode" : $CardRotater/CardRightPivot/CardFacingDir,
		"cardPivotNode" : $CardRotater/CardRightPivot,
		"animationName" : "FlipRight",
		"flipOffsetAngle" : Vector3(0,0,180),
		"playerMoveOffset" : Vector3(-3.5,0,0)
	},
	"DOWN": {
		"cardFacingDirNode" : $CardRotater/CardDownPivot/CardFacingDir,
		"cardPivotNode" : $CardRotater/CardDownPivot,
		"animationName" : "FlipDown",
		"flipOffsetAngle" : Vector3(-180,0,0),
		"playerMoveOffset" : Vector3(0,0,-5)
	},
	"LEFT": {
		"cardFacingDirNode" : $CardRotater/CardLeftPivot/CardFacingDir,
		"cardPivotNode" : $CardRotater/CardLeftPivot,
		"animationName" : "FlipLeft",
		"flipOffsetAngle" : Vector3(0,0,-180),
		"playerMoveOffset" : Vector3(3.5,0,0)
	}
}

var isAnimating = false

func _ready() -> void:
	hint_text_container.visible = false
	
	# Enable player:
	player.canMove = true
	center_card.setFlipDetectorsEnabled(true)
	center_card.refreshAllDoors()

func _on_flip_detector_do_flip(flipDirection:String) -> void:
	if isAnimating:
		return
		
	isAnimating = true
	player.canMove = false
	
	var flippedCard = pivotConfig[flipDirection]["cardFacingDirNode"]
	var flippedCardPivot = pivotConfig[flipDirection]["cardPivotNode"]
	
	proxy_rig.visible = true
	center_card_dir.visible = false
	flippedCardPivot.visible = false # hide pivot 
	
	proxy_rig.global_transform = flippedCard.global_transform
	proxy_facing_dir.global_rotation = flippedCard.global_rotation
	proxy_facing_dir.global_rotation_degrees = Global.getRounded90Vector(proxy_facing_dir.global_rotation_degrees)
	
	var playerMoveOffset = pivotConfig[flipDirection]["playerMoveOffset"] # (0,0,5) Code for TOP
	
	# TODO: make constants:
	var animTime = 1.5
	var tweenTrans:= Tween.TRANS_BOUNCE
	var tweenEase:= Tween.EASE_OUT
	
	# Need to multiply by parent's basis to get correct local offset.
	var playerMoveOffsetRotated = card_rotater.global_transform.basis * playerMoveOffset
	
	var tween = create_tween()
	tween.set_trans(tweenTrans)
	tween.set_ease(tweenEase)
	
	#nudge player a bit...
	var tween2 = create_tween()
	tween2.set_trans(tweenTrans)
	tween2.set_ease(tweenEase)
	
	tween.tween_property(proxy_rig, "global_position", center_card_dir.global_position, animTime)
	tween2.tween_property(player, "global_position", player.global_position + playerMoveOffsetRotated, animTime)
	
	await tween.finished
	await tween2.finished
	center_card_dir.global_position = proxy_rig.global_position
	center_card_dir.global_rotation_degrees = Global.getRounded90Vector(proxy_facing_dir.global_rotation_degrees)
	proxy_rig.visible = false
	center_card_dir.visible = true
	
	# Setup other rigs here...
	center_card.setFlipDetectorsEnabled(false)
	if round(center_card_dir.global_rotation_degrees.x) in [180.0, -180.0]\
		or round(center_card_dir.global_rotation_degrees.z) in [180.0, -180.0]:
		center_card.changeToBack(pivotConfig[flipDirection]["flipOffsetAngle"])
	else:
		center_card.changeToFront(pivotConfig[flipDirection]["flipOffsetAngle"])
	center_card.setFlipDetectorsEnabled(true)
	center_card.refreshAllDoors()
	
	isAnimating = false
	player.canMove = true

func _on_flip_detector_hide_preview(flipDirection:String) -> void:
	if isAnimating:
		return
	isAnimating = true
	player.canMove = false

	$Anim.play_backwards(pivotConfig[flipDirection]["animationName"])
	await $Anim.animation_finished
	
	isAnimating = false
	player.canMove = true

func _on_flip_detector_show_preview(flipDirection:String) -> void:
	if isAnimating:
		return
	isAnimating = true
	player.canMove = false

	# We rotate the card before showing it !!
	var flippedCardNode = pivotConfig[flipDirection]["cardFacingDirNode"]
	flippedCardNode.rotation_degrees = center_card_dir.rotation_degrees\
		+ pivotConfig[flipDirection]["flipOffsetAngle"]
	flippedCardNode.rotation_degrees = Global.getRounded90Vector(flippedCardNode.rotation_degrees)
	$Anim.play(pivotConfig[flipDirection]["animationName"])
	await $Anim.animation_finished
	
	isAnimating = false
	player.canMove = true


func _on_center_card_show_text(textId: String) -> void:
	hint_text_container.visible = true
	hint_text_label.text = "Show text for id '" + textId + "'"


func _on_center_card_hide_text() -> void:
	hint_text_container.visible = false

func _on_center_card_do_card_rotate() -> void:
	if isAnimating:
		return
	isAnimating = true
	player.canMove = false

	# We rotate the card before showing it !!
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card_rotater, "rotation_degrees", 
		card_rotater.rotation_degrees + Vector3(0,90,0), 
		2)
	
	await tween.finished
	
	card_rotater.rotation_degrees = Global.getRounded90Vector(card_rotater.rotation_degrees)
	center_card.refreshAllDoors()
	isAnimating = false
	player.canMove = true

func _on_center_card_door_passage_not_allowed() -> void:
	player.onDoorPassageNotAllowed()
