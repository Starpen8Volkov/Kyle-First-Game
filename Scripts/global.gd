extends Node

var score = 0
var rawKey = preload("res://Scenes/key.tscn")
var Player
var tileMap
var tileSize = Vector2(0,0)
var solids
var borderSize=20
var dynamic
var door
var windowSize=Vector2(800,448)
var main
var Mapname="map1"
var changingScenes=false
var signsText={
	"map1":{
		"(8, 13)":"/n/n/n4 Hi! :)/n/n/n/n/n",
		"(0, 0)":"/n/n/nCorner Sign/n/n/n/n/n",
		"(24, 23)":"/n/nLeft Path - House 1/n/nUp path - House 2/n/nRight Path - Castle/n/n",
		"(38, 7)":"/n/n/n/nHouse 2/n/n/n/n",
		"(41, 24)":"/n/n/n/nCastle/n/n/n/n"
	}
}
var dynamics

# Called when the node enters the scene tree for the first time.
func _ready():
	loadmap(Mapname,true)
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
	node.position = ((Vector2(randi_range(0+borderSize,windowSize.x-borderSize),randi_range(0+borderSize,windowSize.y-borderSize))/Global.tileSize).round()*Global.tileSize)+(Global.tileSize/2)


func loadmap(m,l):
	changingScenes=true
	main=get_tree().get_first_node_in_group("Main")
	if l:
		#get_tree().change_scene_to_file("res://Scenes/map"+str(m)+".tscn")
		var newMap=load("res://Scenes/"+str(m)+".tscn")
		newMap=newMap.instantiate()
		if main.get_node("Map").get_child_count()>0:
			deleteOldmap()
		main.get_node("Map").add_child(newMap)
	
	#if Player!=null:
		#Player.reload()
	Player=get_tree().get_nodes_in_group("player")[-1]
	tileMap = get_tree().get_nodes_in_group("tilemap")[-1]
	tileSize = Vector2(tileMap.tile_set.tile_size)
	solids = get_tree().get_nodes_in_group("solid")
	dynamic = get_tree().get_nodes_in_group("dynamic layer")[-1]
	dynamics = get_tree().get_nodes_in_group("dynamic")
	door = get_tree().get_nodes_in_group("door")[-1]
	changingScenes=false
	#generateKeys(15)

func deleteOldmap():
	var Oldmap=main.get_node("Map").get_child(0)
	Oldmap.queue_free()
