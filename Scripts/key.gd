extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#position.x = randi_range(20,780)
	#position.y = randi_range(20,430)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player"):
		Global.keyCollected()
		delete()

func delete():
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("delete")
	$Timer.wait_time=$AnimationPlayer.current_animation_length
	$Timer.start()

func _on_timer_timeout() -> void:
	queue_free()
