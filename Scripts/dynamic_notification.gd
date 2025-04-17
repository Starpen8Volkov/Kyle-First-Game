extends Sprite2D

var minA=0.2
var maxA=0.8
var dir=1
var tween
var transparency=minA
var started=true

func _process(_delta: float) -> void:
	self_modulate.a=transparency
	print(transparency,self_modulate.a)

func blink():
	#visible=!visible
	if tween!=null:
		tween.kill()
		tween=null
	tween=create_tween()
	if dir>0:
		tween.tween_property(self,"transparency",maxA,$Timer.wait_time)
	elif dir<0:
		tween.tween_property(self,"transparency",minA,$Timer.wait_time)
	dir=0-dir
	
func start(b):
	if started!=b:
		if tween!=null:
			tween.kill()
			tween=null
		visible=b
		started=b
		if b:
			self_modulate.a=minA
			dir=1
			tween=create_tween()
			tween.tween_property(self,"transparency",maxA,$Timer.wait_time)
			tween.tween_callback(start_tween)
		else:
			$Timer.stop()

func start_tween():
	tween=null
	$Timer.start()
	self_modulate.a=maxA
	dir=-1
