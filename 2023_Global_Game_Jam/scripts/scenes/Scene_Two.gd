extends Node

var selected_world : String

func _ready():
	$SceneChange/AnimationPlayer.play("fade_in")

func _on_Next_Scene_body_entered(body):
	if body.is_in_group("player"):
		#selected_world = "res://scenes/Scene_Three.tscn"
		selected_world = "res://scenes/Stage_Three.tscn"
		$SceneChange/AnimationPlayer.play("fade_out")
		
func _on_Back_Scene_body_entered(body):
	if body.is_in_group("player"):
		selected_world = "res://scenes/Scene_One.tscn"
		$SceneChange/AnimationPlayer.play("fade_out")

# make scenes switch
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene(selected_world)
