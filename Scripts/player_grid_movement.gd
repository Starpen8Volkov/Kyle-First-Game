extends CharacterBody2D

var tileMap
var tileSize = Vector2(0,0)
var lastDir = 0
var toMove=Vector2(0,0)
var cam
var sprite
var touches = []
var moveLocks = []

func _ready():
	cam = get_tree().get_first_node_in_group("player_camera")
	sprite = get_tree().get_first_node_in_group("player_sprite")
	tileMap = get_tree().get_first_node_in_group("tilemap") 
	tileSize = Vector2(tileMap.tile_set.tile_size)
	
	position = ((position/tileSize).round()*tileSize)+(tileSize/2)
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
			toMove.x+=(tileSize.x)*directionX
	if directionY!=null && toMove.y==0:
		if lastDir==0 or lastDir==2:
			toMove.y+=(tileSize.y)*directionY

func _on_timer_timeout():
	if toMove==Vector2(0,0):
		sprite.stop()
	else:
		#check collision
		if !touches.any(collidingBodies):
			position+=toMove
			cam.position=position
		
			#animation
			if toMove.x>0:
				sprite.play("right")
			elif toMove.x<0:
				sprite.play("left")
			elif toMove.y>0:
				sprite.play("down")
			elif toMove.y<0:
				sprite.play("up")
		
		toMove=Vector2(0,0)


func collidingBodies(body):
	print(body.position,(toMove+position)-(tileSize/2))
	return body.position==(toMove+position)-(tileSize/2)


func _on_left_body_entered(body):
	if body!=Global.Player:
		touches.append(body)
		#print(body.tile_set.get_physics_layer_collision_layer(2))

func _on_right_body_entered(body):
	if body!=Global.Player:
		touches.append(body)


func _on_top_body_entered(body):
	if body!=Global.Player:
		touches.append(body)


func _on_bottom_body_entered(body):
	if body!=Global.Player:
		touches.append(body)


func _on_left_body_exited(body):
	touches.erase(body)


func _on_right_body_exited(body):
	touches.erase(body)


func _on_top_body_exited(body):
	touches.erase(body)


func _on_bottom_body_exited(body):
	touches.erase(body)
