extends Node

var score = 0
var rawKey = preload("res://Scenes/key.tscn")
var Player

# Called when the node enters the scene tree for the first time.
func _ready():
	Player=get_tree().get_first_node_in_group("player")
	
	generateKeys(15)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Quit_Game"):
		get_tree().quit()


func keyCollected():
	score+=1
	print("Key Collected, Current Score is: "+str(score))
	get_tree().get_first_node_in_group("score").text = str(score)


func generateKeys(num):
	var i=0;
	while(i<num):
		var freshKey=rawKey
		get_tree().get_first_node_in_group("map").add_child(freshKey.instantiate())
		i+=1
