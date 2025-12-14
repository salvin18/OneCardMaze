extends Node

func queueFreeChildren(parent:Node) -> void:
	for child in parent.get_children():
		child.queue_free()

# round to nearest 90, wont exceed 360:
func getRounded90Angle(val:float) -> float:
	# Normalize the angle to be between 0 and 360 degrees (negative possible)
	var wrapped_angle = int(val) % 360

	# Ensure positive
	if wrapped_angle < 0:
		wrapped_angle += 360

	# Round the angle to the nearest 90 degrees
	return round(wrapped_angle / 90.0) * 90.0

func getRounded90Vector(rotation:Vector3) -> Vector3:
	return Vector3(
		getRounded90Angle(rotation.x),
		getRounded90Angle(rotation.y),
		getRounded90Angle(rotation.z)
	)

func isRoundedEqual(vector1:Vector3, vector2:Vector3):
	if is_equal_approx(round(vector1.x), round(vector2.x))\
		and is_equal_approx(round(vector1.y), round(vector2.y))\
		and is_equal_approx(round(vector1.z), round(vector2.z)):
		return true
	return false

func getOppositeDir(dir:String) -> String:
	var opposites := {
		"TOP": "DOWN",
		"DOWN": "TOP",
		"RIGHT" : "LEFT",
		"LEFT" : "RIGHT"
	}
	return opposites[dir]
