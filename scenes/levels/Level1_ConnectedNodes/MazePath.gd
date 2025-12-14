@tool
class_name MazePath
extends Marker3D

signal currentNodeChanged
signal doAFlip(dir:String, foriegnNodeName:String)

@export var connectionsAsStringArr: Array[String] = []        
@export var rotaterNamesArr: Array[String] = []
@export var flipConfigNamesArr:Array[String] = []

@export var refreshLinks: bool:
	set(value):
		_refreshLinks()

const ALLOWED_DIRS = ["LEFT","RIGHT","UP","DOWN"]
const REVERSE_DIRS := {"LEFT":"RIGHT","RIGHT":"LEFT","UP":"DOWN","DOWN":"UP"}

# state vars:s
var currentNodeName:String:
	set(val):
		currentNodeName = val
		emit_signal("currentNodeChanged")

# Dictionaries 
var nodeNamesRefs := {} # nodeName:<Object>
var connections := {} # "nodeName": { "LEFT" : "nodeName", "RIGHT":"nodeName" }
var flipNodes := {} # "nodeName" : { "DOWN" : "MazePath2NodeName"}


func _refreshLinks():
	nodeNamesRefs = {}
	connections = {}
	flipNodes = {}
	clearRayCasts()
	populateConnections()
	populateFlipNodes()
	print("flipNodes ", flipNodes)
	#prettyPrintConnections()
	#refreshConnectionsAsString()

func clearRayCasts() -> void:
	for child in get_children():
		if child is Marker3D:
			nodeNamesRefs[child.name] = child
			## Clear existing ray casts
			for rayCasts in child.get_children():
				if rayCasts is RayCast3D:
					rayCasts.queue_free()

func populateConnections() -> void:
	for connection in connectionsAsStringArr:
		var splitArr = connection.split("-")
		if splitArr.size() == 3:
			var node1 = splitArr[0]
			var dir = splitArr[1]
			var node2 = splitArr[2]
			addConnection(node1, dir, node2)
			addConnection(node2, REVERSE_DIRS[dir], node1)

func populateFlipNodes() -> void:
	for flipConfig in flipConfigNamesArr:
		var splitArr = flipConfig.split("-")
		if splitArr.size() == 3:
			var node1 = splitArr[0]
			var dir = splitArr[1]
			var node2 = splitArr[2]
			addFlip(node1, dir, node2)

# Deprecated, I dont want this:
func refreshConnectionsAsString():
	var newConnectionsAsStr: Array[String] = [] 
	for nodeFrom in connections:
		var directionObj = connections[nodeFrom]
		for dir in directionObj:
			newConnectionsAsStr.append(nodeFrom + "-" + dir + "-" + directionObj[dir])
	connectionsAsStringArr = newConnectionsAsStr
	
# Called externally one during run
func init(startNodeName) -> void:
	_refreshLinks()
	currentNodeName = startNodeName

# Move functions:
func attempMove(dir) -> void:
	var directionObj:Dictionary = connections[currentNodeName]
	if directionObj.has(dir):
		var newCurrent = directionObj.get(dir)
		currentNodeName = newCurrent
	elif flipNodes.has(currentNodeName):
		var flipDirectionObj = flipNodes[currentNodeName]
		if flipDirectionObj.has(dir):
			var foriegnNode = flipDirectionObj[dir]
			emit_signal("doAFlip", dir, foriegnNode)
	
	

func getCurrentNode():
	return nodeNamesRefs[currentNodeName]

func canRotate():
	return rotaterNamesArr.has(currentNodeName)

func addConnection(node1Name:String, dir:String, node2Name:String):
	if (nodeNamesRefs.has(node1Name)
		and nodeNamesRefs.has(node2Name)
		and ALLOWED_DIRS.has(dir)
	):
		var dirConnectionObj = {}
		if connections.has(node1Name):
			dirConnectionObj = connections[node1Name]
		dirConnectionObj[dir] = node2Name
		connections[node1Name] = dirConnectionObj
		if Engine.is_editor_hint():
			showEditorGizmo(node1Name, node2Name)

func addFlip(node1Name:String, dir:String, foriegnNode:String):
	if (nodeNamesRefs.has(node1Name)
		and ALLOWED_DIRS.has(dir)
	):
		var dirConfig = {}
		if flipNodes.has(node1Name):
			dirConfig = flipNodes[node1Name]
		dirConfig[dir] = foriegnNode
		flipNodes[node1Name] = dirConfig

func showEditorGizmo(node1Name:String, node2Name:String):
	var node1:Marker3D = nodeNamesRefs[node1Name]
	var node2:Marker3D = nodeNamesRefs[node2Name]
	var raycast:RayCast3D = RayCast3D.new()
	raycast.name = "EditorVisual-" + node1Name + "-" + node2Name + str(randi())
	raycast.enabled = true
	node1.add_child(raycast)
	raycast.owner = node1.get_owner() # ensure it saves in the scene
	# We can set this only after adding it:
	raycast.target_position = raycast.to_local(node2.global_transform.origin)

func prettyPrintConnections():
	for child in connections:
		print (child, " --> ", connections[child])
