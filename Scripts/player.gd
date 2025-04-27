extends CharacterBody2D

var lastDir = "left"
var toMove=Vector2(0,0)
var cam
var sprite
var touches = {
	'left':[],
	'right':[],
	'top':[],
	'bottom':[],
	'middle':[]
}
var collisionAreas = {
	'left':null,
	'right':null,
	'top':null,
	'bottom':null,
	'middle':null
}
var Tiledirections
var interactable=false
var startDirection
var nextMove
var stoppedScript=false

func _physics_process(_delta):
	pass

func _ready():
	cam = get_tree().get_first_node_in_group("player_camera")
	sprite = get_tree().get_first_node_in_group("player_sprite")
	collisionAreas = {
		'left':$"Collision Detection/Left",
		'right':$"Collision Detection/Right",
		'top':$"Collision Detection/Top",
		'bottom':$"Collision Detection/Bottom",
		'middle':$"Collision Detection/Middle"
	}
	Tiledirections={
		'left':Vector2(-1*Global.tileSize.x,0),
		'right':Vector2(1*Global.tileSize.x,0),
		'top':Vector2(0,-1*Global.tileSize.y),
		'bottom':Vector2(0,1*Global.tileSize.y),
		'middle':Vector2(0,0)
	}
	startDirection=get_meta("Direction")
	
	position = ((position/Global.tileSize).round()*Global.tileSize)+(Global.tileSize/2)
	cam.position=position
	
	sprite.play(startDirection)

func _process(_delta):
	if !stoppedScript:
		#   movement script
		var directionX = Input.get_axis("Player_Left","Player_Right")
		var directionY = Input.get_axis("Player_Up","Player_Down")
		
		if Input.is_action_just_pressed("Player_Up"):
			lastDir="top"
		if Input.is_action_just_pressed("Player_Right"):
			lastDir="right"
		if Input.is_action_just_pressed("Player_Down"):
			lastDir="bottom"
		if Input.is_action_just_pressed("Player_Left"):
			lastDir="left"
		
		if directionX!=null && toMove.x==0:
			if lastDir=="left" or lastDir=="right":
				toMove=Vector2((Global.tileSize.x)*directionX,0)
		if directionY!=null && toMove.y==0:
			if lastDir=="top" or lastDir=="bottom":
				toMove=Vector2(0,(Global.tileSize.y)*directionY)
		
		#interactables
		if collisionAreas[lastDir].get_overlapping_bodies().any(are_dynamic):
			$ButtonE.position=Tiledirections[lastDir]*10
			$ButtonE.start(true)
			interactable=true
			if Input.is_action_just_pressed("Interact"):
				interact(collisionAreas[lastDir])
		else:
			$ButtonE.start(false)
			interactable=false
		
		#teleport
		if collisionAreas["middle"].get_overlapping_bodies().any(are_open_door.bind(collisionAreas["middle"])):
			stopscript()
			Global.loadmap("House Indoor",true)
			
		#position update
		if nextMove!=null:
			movePlayerTo(nextMove)
			nextMove=null


func _on_timer_timeout():
	if !stoppedScript:
		if toMove==Vector2(0,0):
			sprite.stop()
		else:
			#animation & movement/collision
			var allowedToMove=false
			if toMove.x<0:
				if !collisionAreas['left'].get_overlapping_bodies().any(areSolid):
					allowedToMove=true
				sprite.play("left")
			elif toMove.x>0:
				if !collisionAreas['right'].get_overlapping_bodies().any(areSolid):
					allowedToMove=true
				sprite.play("right")
			elif toMove.y>0:
				if !collisionAreas['bottom'].get_overlapping_bodies().any(areSolid):
					allowedToMove=true
				sprite.play("down")
			elif toMove.y<0:
				if !collisionAreas['top'].get_overlapping_bodies().any(areSolid):
					allowedToMove=true
				sprite.play("up")
			
			if allowedToMove:
				nextMove=position+toMove
			
			toMove=Vector2(0,0)

func areSolid(body):
	return Global.solids.has(body)

func movePlayerTo(pos):
	position=pos
	cam.position=pos

func are_dynamic(body):
	return Global.dynamics.has(body)

func interact(area):
	#print(Global.doors[0].get_cell_source_id((Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize)))," ",Global.doors[0].get_cell_tile_data((Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize))).get_custom_data("door"))
	if area.get_overlapping_bodies().any(areDoor.bind(area)):
		if area.get_overlapping_bodies().any(areClosedDoor):
			Global.doors[0].erase_cell(Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize))
		else:
			Global.doors[0].set_cell(Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize),1,Vector2i(1,7))
			position=position

func areDoor(body,area):
	return body.get_cell_tile_data((Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize))).get_custom_data("door")

func areClosedDoor(body):
	return Global.doors.has(body)

func are_open_door(body,area):
	var cellData=body.get_cell_tile_data((Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize)))
	if body==null or cellData==null:
		return false
	return cellData.get_custom_data("open_door")

func stopscript():
	$Timer.stop()
	stoppedScript=true
