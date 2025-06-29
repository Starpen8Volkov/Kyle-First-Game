extends Node2D

var spd=20.0
var max_progress
var curve
var points=[]
var progress=0
var previous_tile
var npc=[]
var running=false

func _ready() -> void:
	spd=Global.tileSize.x

func _process(delta: float) -> void:
	#get_parent().progress=lerp(start, 200.0, merge)
	#merge+=(spd/100)*delta
	#if get_parent().progress>=max_progress:
		#print("done")
	
	if running:
		if progress>=max_progress:
			progress-=1
			position=points[progress]
			running=false
			#print("finish")
		elif position.distance_to(points[progress])<spd/4:
			position=points[progress]
			progress+=1
			#print(progress," ",position)
		else:
			if previous_tile!=null:
				Global.solid_dynamic.set_cell(previous_tile[0], previous_tile[1], previous_tile[2])
			
			position=position.move_toward(points[progress],spd*delta)
			#print(points[progress])
			var p=(((position/Global.tileSize).round()*Global.tileSize)-(Global.tileSize/2))/Global.tileSize
			previous_tile=[p,Global.solid_dynamic.get_cell_source_id(p),Global.solid_dynamic.get_cell_atlas_coords(p)]
			Global.solid_dynamic.set_cell(p,npc[0],npc[1])

func start_path(arr):
	var id=arr[0]
	var pos=arr[1]
	if !running:
		running=true
		progress=0
		previous_tile=[pos, -1, Vector2i(-1, -1)]
		npc=[Global.solid_dynamic.get_cell_source_id(pos), Global.solid_dynamic.get_cell_atlas_coords(pos)]
		curve=get_parent().get_node(id)
		max_progress=curve.curve.point_count
		for i in max_progress:
			var p=curve.curve.get_point_position(i)
			p=((p/Global.tileSize).round()*Global.tileSize)
			points.append(p)
			curve.curve.set_point_position(i,p)
		position=points[progress]

func finish():
	if running:
		position=points[-1]
		if previous_tile!=null:
			Global.solid_dynamic.set_cell(previous_tile[0], previous_tile[1], previous_tile[2])
		
		#print(points[progress])
		var p=(((position/Global.tileSize).round()*Global.tileSize)-(Global.tileSize/2))/Global.tileSize
		previous_tile=[p,Global.solid_dynamic.get_cell_source_id(p),Global.solid_dynamic.get_cell_atlas_coords(p)]
		Global.solid_dynamic.set_cell(p,npc[0],npc[1])
