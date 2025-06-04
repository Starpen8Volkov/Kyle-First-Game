extends Node2D

var nav
var spd=1.0

func _ready() -> void:
	$NavigationAgent2D.path_desired_distance=1.0

func _process(delta: float) -> void:
	get_parent().progress=lerp(get_parent().progress, 200.0,spd/100)
 
