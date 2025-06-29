extends Control

var up
var down
var left
var right
var center

func _ready():
	up = $Up
	down = $Down
	left = $Left
	right = $Right
	center = $Center

func _process(delta):
	var axis=Vector2((0-int(left.button_pressed))+int(right.button_pressed), (0-int(up.button_pressed))+int(down.button_pressed))
	var last_dir
	Global.Player.joystick_axis=axis
	if axis.x>0:
		last_dir="right"
	elif axis.x<0:
		last_dir="left"
	elif axis.y>0:
		last_dir="bottom"
	elif axis.y<0:
		last_dir="top"
	if last_dir!=null:
		Global.Player.joystick_last_dir=last_dir
	
	Global.Player.joystick_center=center.button_pressed
