extends Node

var selected_world : String

func _ready():
	if GameController.just_started:
		$YSort/Player.position = Vector2(64, -24)
		GameController.just_started = false
	else:
		$YSort/Player.position = Vector2(276, -24)
		$YSort/Player.get_child(0).facing = -1
		
	$SceneChange/AnimationPlayer.play("fade_in")

func _on_Next_Scene_body_entered(body):
	if body.is_in_group("player"):
		selected_world = "res://scenes/Scene_Two.tscn"
		$SceneChange/AnimationPlayer.play("fade_out")

# make scenes switch
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		print("fade")
		get_tree().change_scene(selected_world)
