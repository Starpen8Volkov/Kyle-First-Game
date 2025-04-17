extends Node

var score = 0
var rawKey = preload("res://Scenes/key.tscn")
var Player
var tileMap
var tileSize = Vector2(0,0)
var solids
var borderSize=20
var dynamics

# Called when the node enters the scene tree for the first time.
func _ready():
	loadmap(1,false)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Quit_Game"):
		get_tree().quit()


func keyCollected():
	score+=1
	print("Key Collected, Current Score is: "+str(score))
	get_tree().get_first_node_in_group("score").text = str(score)


func generateKeys(num):
	for i in num:
		var freshKey=rawKey
		freshKey=freshKey.instantiate()
		get_tree().get_first_node_in_group("map").add_child(freshKey)
		chooseRandomTile(freshKey)


func chooseRandomTile(node):
	node.position = ((Vector2(randi_range(0+borderSize,800-borderSize),randi_range(0+borderSize,450-borderSize))/Global.tileSize).round()*Global.tileSize)+(Global.tileSize/2)


func loadmap(m,l):
	if l:
		get_tree().change_scene_to_file("res://Scenes/map"+str(m)+".tscn")
	
	Player=get_tree().get_first_node_in_group("player")
	tileMap = get_tree().get_first_node_in_group("tilemap") 
	tileSize = Vector2(tileMap.tile_set.tile_size)
	solids = get_tree().get_nodes_in_group("solid")
	dynamics = get_tree().get_nodes_in_group("dynamic")
	
	generateKeys(15)
