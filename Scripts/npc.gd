extends Node2D

var nav
var spd=10.0
var start
var merge=0
var max_progress

func _ready() -> void:
	get_parent().progress=1000
	max_progress=get_parent().progress
	get_parent().progress=0
	start=get_parent().progress

func _process(delta: float) -> void:
	get_parent().progress=lerp(start, 200.0, merge)
	merge+=(spd/100)*delta
	if get_parent().progress>=max_progress:
		print("done")
