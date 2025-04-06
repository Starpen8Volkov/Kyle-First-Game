extends CharacterBody2D

var tileMap
var tileSize = Vector2(0,0)
var lastDir = 0
var toMove=Vector2(0,0)
var cam
var sprite
var touches = []
var moveLocks = []
var rects
var toMoveP = toMove
var pPos = Vector2(0,0)

func _ready():
	rects = get_tree().get_nodes_in_group("rect")
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
	
	
	#print(touches,toMove+position)
	if toMove==Vector2(0,0):
		sprite.stop()
	else:
		print(position+toMove,touches)
		#var i=0
		#for r in touches:
			#rects[i].position=r[1]-Vector2(7.5,7.5)
			#i+=1
		#check collision
		if !touches.any(collidingBodies):
			toMoveP=toMove
			call_deferred("moveplayer")
		
		#animation
		#var moved = true
		if toMove.x>0:
			sprite.play("right")
		elif toMove.x<0:
			sprite.play("left")
		elif toMove.y>0:
			sprite.play("down")
		elif toMove.y<0:
			sprite.play("up")
		#else:
			#moved=false
		
		toMove=Vector2(0,0)

func _on_timer_timeout():
	pass


func moveplayer():
	pPos=position
	position+=toMoveP
	cam.position=position


func collidingBodies(body):
	#print(body[1],(toMove+position))
	return body[1]==(toMove+position)


func checkBodyByPos(b,pos):
	return b[1]==pos


func _on_left_body_entered(body):
	if body!=Global.Player:
		touches.append([body,position+Vector2(-tileSize.x,0)])
		rects[0].position=(position+Vector2(-tileSize.x,0))-(tileSize/2)
		rects[0].get_node("Label").text=str(rects[0].position+(tileSize/2))
		print("+l"+str(touches))
		#print(body.tile_set.get_physics_layer_collision_layer(2))

func _on_right_body_entered(body):
	if body!=Global.Player:
		touches.append([body,position+Vector2(tileSize.x,0)])
		rects[1].position=(position+Vector2(tileSize.x,0))-(tileSize/2)
		rects[1].get_node("Label").text=str(rects[1].position+(tileSize/2))
		print("+r"+str(touches))


func _on_top_body_entered(body):
	if body!=Global.Player:
		touches.append([body,position+Vector2(0,-tileSize.y)])
		rects[2].position=(position+Vector2(0,-tileSize.y))-(tileSize/2)
		rects[2].get_node("Label").text=str(rects[2].position+(tileSize/2))
		print("+t"+str(touches))


func _on_bottom_body_entered(body):
	if body!=Global.Player:
		touches.append([body,position+Vector2(0,tileSize.y)])
		rects[3].position=(position+Vector2(0,tileSize.y))-(tileSize/2)
		rects[3].get_node("Label").text=str(rects[3].position+(tileSize/2))
		print("+b"+str(touches))


func _on_left_body_exited(body):
	touches.pop_at(touches.find_custom(checkBodyByPos.bind(pPos+Vector2(-tileSize.x,0))))
	rects[0].position=Vector2(0,0)
	print("-l"+str(pPos+Vector2(-tileSize.x,0)))


func _on_right_body_exited(body):
	touches.pop_at(touches.find_custom(checkBodyByPos.bind(pPos+Vector2(tileSize.x,0))))
	rects[1].position=Vector2(0,0)
	print("-r"+str(pPos+Vector2(tileSize.x,0)))


func _on_top_body_exited(body):
	touches.pop_at(touches.find_custom(checkBodyByPos.bind(pPos+Vector2(0,-tileSize.y))))
	rects[2].position=Vector2(0,0)
	print("-t"+str(pPos+Vector2(0,-tileSize.y)))


func _on_bottom_body_exited(body):
	touches.pop_at(touches.find_custom(checkBodyByPos.bind(pPos+Vector2(0,tileSize.y))))
	rects[3].position=Vector2(0,0)
	print("-b"+str(pPos+Vector2(0,tileSize.y)))
