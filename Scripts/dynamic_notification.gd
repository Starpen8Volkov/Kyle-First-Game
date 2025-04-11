extends Sprite2D

var minA=50
var maxA=200
var dir=-1
var tween
var transparency=maxA
var started=false

func _process(_delta: float) -> void:
	modulate.a=transparency
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
		if b:
			$Timer.start()
		else:
			$Timer.stop()
		visible=b
		started=b
