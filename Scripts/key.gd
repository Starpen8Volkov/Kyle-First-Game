extends Area2D

var speed=1.2
var rot_speed=1.2
var final_rot=1080
var killed

func _on_body_entered(body):
	if body.is_in_group("player"):
		Global.keyCollected()
		delete()

func delete():
	killed=true
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("delete")
	$Timer.wait_time=$AnimationPlayer.current_animation_length
	$Timer.start()

func _on_timer_timeout() -> void:
	Global.purge("items", self)

func enter(bag, pos):
	$CollisionPolygon2D.disabled=true
	global_position=(Vector2(bag)*Global.tileSize)+(Global.tileSize/2)
	var tween=create_tween()
	tween.tween_property(self, "global_position", (Vector2(pos)*Global.tileSize)+(Global.tileSize/2), speed)
	tween.tween_callback(entered)
	var tween2=create_tween()
	tween2.tween_property($Sprite2D, "rotation_degrees", final_rot, rot_speed)

func entered():
	$CollisionPolygon2D.disabled=false
