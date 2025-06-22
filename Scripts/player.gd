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
var signOnScreen=false
var dynamics=[]
var pausedmovement=false
var npc

func _physics_process(_delta):
	pass

func reload():
	cam = get_tree().get_nodes_in_group("player_camera")[-1]
	sprite = get_tree().get_nodes_in_group("player_sprite")[-1]
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
	
	resetPosition()
	
	sprite.play(startDirection)

func _ready():
	reload()

func _process(_delta):
	if !stoppedScript:
		#   movement script
		var directionX = Input.get_axis("Player_Left","Player_Right")
		var directionY = Input.get_axis("Player_Up","Player_Down")
		
		if !pausedmovement:
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
		else:
			if Input.is_action_just_pressed("Player_Right") or Input.is_action_just_pressed("Player_Down"):
				if npc.get_custom_data("npc_say")<Global.npclimits[npc.get_custom_data("npc_name")][1]:
					npc.set_custom_data("npc_say",npc.get_custom_data("npc_say")+1)
					update_dialogue(npc)
			if Input.is_action_just_pressed("Player_Left") or Input.is_action_just_pressed("Player_Up"):
				if npc.get_custom_data("npc_say")>Global.npclimits[npc.get_custom_data("npc_name")][0]:
					npc.set_custom_data("npc_say",npc.get_custom_data("npc_say")-1)
					update_dialogue(npc)
		
		#interactables
		dynamics=[]
		if collisionAreas[lastDir].get_overlapping_bodies().any(are_dynamic.bind(collisionAreas[lastDir])):
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
			var tileData=get_door_location(Global.dynamic,collisionAreas["middle"])
			Global.loadmap(true, tileData[0], tileData[1], tileData[2])
		
		#position update
		if nextMove!=null:
			movePlayerTo(nextMove)
			nextMove=null


func _on_timer_timeout():
	if !stoppedScript:
		if toMove==Vector2(0,0):
			update_sprite("stop")
		else:
			#animation & movement/collision
			var allowedToMove=false
			if toMove.x<0:
				if !collisionAreas['left'].get_overlapping_bodies().any(areSolid):
					allowedToMove=true
				update_sprite("left")
			elif toMove.x>0:
				if !collisionAreas['right'].get_overlapping_bodies().any(areSolid):
					allowedToMove=true
				update_sprite("right")
			elif toMove.y>0:
				if !collisionAreas['bottom'].get_overlapping_bodies().any(areSolid):
					allowedToMove=true
				update_sprite("down")
			elif toMove.y<0:
				if !collisionAreas['top'].get_overlapping_bodies().any(areSolid):
					allowedToMove=true
				update_sprite("up")
			
			if allowedToMove:
				nextMove=position+toMove
			
			toMove=Vector2(0,0)

func areSolid(body):
	return Global.solids.has(body)

func movePlayerTo(pos):
	if is_instance_valid(cam):
		position=pos
		cam.position=pos
		if signOnScreen:
			$Sign/CanvasLayer.visible=false
			signOnScreen=false

func are_dynamic(body, area):
	if body!=null and Global.dynamics.has(body):
		var tile=body.get_cell_tile_data((Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize)))
		dynamics.append(tile)
		return true
	return false

func interact(area):
	if dynamics.any(areDoor):
		print(dynamics, dynamics.any(areLockedDoor),dynamics[0].get_custom_data("locked_door"))
		if area.get_overlapping_bodies().any(areLockedDoor.bind(area)):
			if Global.keys>0:
				Global.addKeys(-1)
				Global.door.set_cell(Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize),1,Vector2i(1,7))
		elif area.get_overlapping_bodies().any(areClosedDoor):
			Global.door.erase_cell(Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize))
		else:
			Global.door.set_cell(Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize),1,Vector2i(1,7))
			position=position
	
	if dynamics.any(areSign):
		if signOnScreen:
			$Sign/CanvasLayer.visible=false
			signOnScreen=false
		else:
			$Sign/CanvasLayer.visible=true
			$Sign/CanvasLayer/Label.text=Global.signsText[Global.Mapname][str(Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize))]
			signOnScreen=true
	
	if dynamics.any(areMoneybag):
		var p=Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize)
		for item in Global.moneybagItems[Global.Mapname][str(p)]:
			var new_item=Global.collectables[Global.moneybagItems[Global.Mapname][str(p)][item]].instantiate()
			Global.Map.add_child(new_item)
			item=item.lstrip("(")
			item=item.rstrip(")")
			item=item.split(", ")
			item=Vector2(int(item[0]), int(item[1]))
			new_item.enter(p, item)
		Global.solid_dynamic.erase_cell(Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize))
	
	if dynamics.any(areNPC):
		Global.in_dialogue=!Global.in_dialogue
		Global.npc_face.get_parent().visible=Global.in_dialogue
		pausedmovement=Global.in_dialogue
		if Global.in_dialogue:
			update_dialogue(dynamics[0])

func areDoor(tile):
	if tile!=null:
		return tile.get_custom_data("door")
	return false 
	
func areLockedDoor(body, area):
	if Global.door==body:
		var tile=body.get_cell_tile_data((Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize)))
		return tile.get_custom_data("locked_door")
	return false 

func areSign(tile):
	if tile!=null:
		return tile.get_custom_data("sign")
	return false

func areClosedDoor(body):
	return Global.door==body

func are_open_door(body,area):
	var cellData=body.get_cell_tile_data((Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize)))
	if body==null or cellData==null:
		return false
	return cellData.get_custom_data("open_door")

func get_door_location(body,area):
	var cellData=body.get_cell_tile_data(Vector2i((area.global_position-(Global.tileSize/2))/Global.tileSize))
	if body==null or cellData==null:
		return false
	return [cellData.get_custom_data("location"), cellData.get_custom_data("player_pos"), cellData.get_custom_data("player_dir")]

func stopscript():
	$Timer.stop()
	stoppedScript=true

func update_sprite(s):
	if is_instance_valid(sprite):
		if s=="stop":
			sprite.stop()
		else:
			sprite.play(s)

func resetPosition():
	position = ((position/Global.tileSize).round()*Global.tileSize)-(Global.tileSize/2)
	cam.position=position

func areMoneybag(tile):
	if tile!=null:
		return tile.get_custom_data("moneybag")
	return false 

func areNPC(tile):
	if tile!=null:
		return tile.get_custom_data("npc")
	return false

func update_dialogue(n):
	npc=n
	if Global.npcdialogues[npc.get_custom_data("npc_name")][npc.get_custom_data("npc_say")] is Array:
		Global.in_dialogue=false
		Global.npc_face.get_parent().visible=Global.in_dialogue
		pausedmovement=Global.in_dialogue
		Global.nav.start_path(Global.npcdialogues[npc.get_custom_data("npc_name")][npc.get_custom_data("npc_say")])
		npc.set_custom_data("npc_say",npc.get_custom_data("npc_say")+1)
		Global.npclimits[npc.get_custom_data("npc_name")][0]=npc.get_custom_data("npc_say")
	else: 
		Global.npc_face.play(npc.get_custom_data("npc_name"))
		Global.npc_text.text=Global.npcdialogues[npc.get_custom_data("npc_name")][npc.get_custom_data("npc_say")]
	resetPosition()
