extends CharacterBody2D

var lastDir = 0
var toMove=Vector2(0,0)
var cam
var sprite
var touches = {
	'left':[],
	'right':[],
	'top':[],
	'bottom':[]
}
var collisionAreas = {
	'left':null,
	'right':null,
	'top':null,
	'bottom':null
}

func _physics_process(_delta):
	pass

func _ready():
	cam = get_tree().get_first_node_in_group("player_camera")
	sprite = get_tree().get_first_node_in_group("player_sprite")
	collisionAreas = {
		'left':$"Collision Detection/Left",
		'right':$"Collision Detection/Right",
		'top':$"Collision Detection/Top",
		'bottom':$"Collision Detection/Bottom"
	}
	
	position = ((position/Global.tileSize).round()*Global.tileSize)+(Global.tileSize/2)
	cam.position=position

func _process(_delta):
	#   movement script
	var directionX = Input.get_axis("Player_Left","Player_Right")
	var directionY = Input.get_axis("Player_Up","Player_Down")
	
	if Input.is_action_just_pressed("Player_Up"):
		lastDir=0
	if Input.is_action_just_pressed("Player_Right"):
		lastDir=1
	if Input.is_action_just_pressed("Player_Down"):
		lastDir=2
	if Input.is_action_just_pressed("Player_Left"):
		lastDir=3
	
	if directionX!=null && toMove.x==0:
		if lastDir==1 or lastDir==3:
			toMove=Vector2((Global.tileSize.x)*directionX,0)
	if directionY!=null && toMove.y==0:
		if lastDir==0 or lastDir==2:
			toMove=Vector2(0,(Global.tileSize.y)*directionY)
	
	#interactables
	if lastDir==0:
		#top
		if collisionAreas["top"].get_overlapping_bodies().any(are_dynamic):
			pass

func _on_timer_timeout():
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
			movePlayerTo(position+toMove)
		
		toMove=Vector2(0,0)

func areSolid(body):
	return Global.solids.has(body)

func movePlayerTo(pos):
	position=pos
	cam.position=pos

func are_dynamic(body):
	return Global.dynamics.has(body)
