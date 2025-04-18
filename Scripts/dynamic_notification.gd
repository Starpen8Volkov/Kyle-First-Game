extends Sprite2D

var minA=0.0
var maxA=0.6
var dir=1
var tween
var tween2
var transparency=minA
var started=true

func _process(_delta: float) -> void:
	self_modulate.a=transparency

func blink():
	#visible=!visible
	if tween!=null:
		tween.kill()
		tween=null
		#print("killed")
	tween=create_tween()
	if dir>0:
		tween.tween_property(self,"transparency",maxA,$Timer.wait_time)
		tween.tween_callback(reset.bind(maxA))
	elif dir<0:
		tween.tween_property(self,"transparency",minA,$Timer.wait_time)
		tween.tween_callback(reset.bind(minA))
	dir=0-dir
	
func start(b):
	if started!=b:
		if tween2!=null:
			tween2.kill()
			tween2=null
		if tween!=null:
			tween.kill()
			tween=null
		started=b
		if b:
			transparency=minA
			dir=1
			visible=true
			tween2=create_tween()
			tween2.tween_property(self,"transparency",maxA,$Timer.wait_time)
			tween2.tween_callback(start_tween)
		else:
			dir=-1
			$Timer.stop()
			tween2=create_tween()
			tween2.tween_property(self,"transparency",minA,($Timer.wait_time/(maxA-minA))*(transparency-minA))
			tween2.tween_callback(stop_tween)

func start_tween():
	tween2=null
	$Timer.start()
	transparency=maxA
	dir=-1

func stop_tween():
	tween2=null
	transparency=minA
	dir=1
	visible=false

func reset(a):
	transparency=a
