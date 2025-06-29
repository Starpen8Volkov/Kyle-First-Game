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
var moneybagItems={
	"map1":{
		"(4, 14)":{"(3, 14)":"coin", "(5, 14)":"coin", "(4, 13)":"key", "(4, 15)":"key"}
	}
}
var dynamics
var collectables={}
var Map
var solid_dynamic
var npc_face
var npc_text
var in_dialogue=false
var npcdialogues={
	"Jeff":[
		"Hello!\nWelcome to HELL!!!",
		"JK",
		["Jeff1", Vector2i(6, 11)],
		"lol",
		"soz"
	]
}
var npclimits={
	"Jeff":[0, npcdialogues["Jeff"].size()-1]
}
var nav
var keys=0
var keys_sprite
var keys_text
var progress={
	"maps":{
		
	}
}
var items

# Called when the node enters the scene tree for the first time.
func _ready():
	collectables={
		"key": preload("res://Scenes/key.tscn"),
		"coin": preload("res://Scenes/coin.tscn")
	}
	npc_face = get_tree().get_first_node_in_group("npc_face")
	npc_text = get_tree().get_first_node_in_group("npc_text")
	keys_sprite = get_tree().get_first_node_in_group("keys_sprite")
	keys_text = get_tree().get_first_node_in_group("keys_text")
	keys_sprite.visible=false
	keys_text.visible=false
	loadmap(true, Mapname)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Quit_Game"):
		get_tree().quit()


func keyCollected():
	addKeys(1)
	print("Key Collected, Current Amount of Keys is: "+str(keys))

func coinCollected():
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


func loadmap(l, map, pos=null, dir=null):
	changingScenes=true
	main=get_tree().get_first_node_in_group("Main")
	if l:
		#get_tree().change_scene_to_file("res://Scenes/map"+str(m)+".tscn")
		var newMap
		if progress["maps"].has(map):
			newMap=progress["maps"][map]
		else:
			newMap=load("res://Scenes/"+str(map)+".tscn")
		newMap=newMap.instantiate()
		if main.get_node("Map").get_child_count()>0:
			deleteOldmap(Mapname)
		main.get_node("Map").add_child(newMap)
		Mapname=map
	
	Map=get_tree().get_nodes_in_group("map")[-1]
	Player=get_tree().get_nodes_in_group("player")[-1]
	tileMap = get_tree().get_nodes_in_group("tilemap")[-1]
	tileSize = Vector2(tileMap.tile_set.tile_size)
	solids = get_tree().get_nodes_in_group("solid")
	dynamic = get_tree().get_nodes_in_group("dynamic layer")[-1]
	dynamics = get_tree().get_nodes_in_group("dynamic")
	door = get_tree().get_nodes_in_group("door")[-1]
	solid_dynamic = get_tree().get_nodes_in_group("solid_dynamic")[-1]
	nav = get_tree().get_nodes_in_group("nav")[-1]
	items = get_tree().get_nodes_in_group("item")
	
	if pos!=null:
		Player.position=pos
		Player.resetPosition()
	if dir!=null:
		Player.update_sprite(dir)
	changingScenes=false
	#generateKeys(15)

func deleteOldmap(m):
	for i in items:
		if is_instance_valid(i):
			if i.killed:
				purge("items", i)
	nav.finish()
	var Oldmap=main.get_node("Map").get_child(0)
	var packed_map=PackedScene.new()
	packed_map.pack(Oldmap)
	progress["maps"][m]=packed_map
	Oldmap.queue_free()

func addKeys(i):
	keys+=i
	if keys<=0:
		keys_sprite.visible=false
		keys_text.visible=false
	elif keys==1:
		keys_sprite.visible=true
		keys_text.visible=false
	else:
		keys_sprite.visible=true
		keys_text.visible=true
		keys_text.text="x"+str(keys)

func purge(array, item):
	if self[array].has(item):
		self[array].erase(item)
		item.queue_free()
