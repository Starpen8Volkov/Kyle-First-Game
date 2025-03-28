extends CharacterBody2D


var speed = 50.0
var sprite
var direction = -1


func _ready():
	sprite = $AnimatedSprite2D


func _physics_process(_delta):
	#determine direction
	var directionX = Input.get_axis("Player_Left","Player_Right")
	var directionY = Input.get_axis("Player_Up","Player_Down")
	
	if Input.is_action_just_pressed("Player_Down") or Input.is_action_just_pressed("Player_Up"):
		direction = -1
	elif Input.is_action_just_pressed("Player_Left") or Input.is_action_just_pressed("Player_Right"):
		direction = 1
	
	if !directionX and !directionY or directionX==0 and direction==0:
		direction=0
	
	#walking
	if directionX and direction==1:
		velocity.x = directionX * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if directionY and direction==-1:
		velocity.y = directionY * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	
	#animating walking
	if direction==1:
		if directionX<0:
			sprite.play("left")
		elif directionX>0:
			sprite.play("right")
	elif direction==-1:
		if directionY<0:
			sprite.play("up")
		elif directionY>0:
			sprite.play("down")
	else:
		sprite.stop()
	
	move_and_slide()
