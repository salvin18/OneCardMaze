extends CharacterBody3D

const SPEED = 1.85
var canMove = false

var isAnimating := false
var headOriginalPos:Vector3

func _ready() -> void:
	headOriginalPos = $HeadMesh.position

func onDoorPassageNotAllowed() -> void:
	if isAnimating:
		return
	isAnimating = true
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	var nodDistance = 0.4
	tween.tween_property($HeadMesh, "position", headOriginalPos + Vector3(0, nodDistance, 0), 0.07)
	tween.tween_property($HeadMesh, "position", headOriginalPos, 0.14)
	
	await tween.finished
	$HeadMesh.position = headOriginalPos
	isAnimating = false

func _physics_process(delta: float) -> void:
	# Do nothing if we cant move
	if !canMove:
		return
	
	# Add the gravity.
	velocity += get_gravity()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
