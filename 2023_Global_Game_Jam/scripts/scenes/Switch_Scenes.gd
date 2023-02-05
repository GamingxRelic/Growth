extends Node

var next_world

onready var current_world = $Scene_One
onready var animation_player = $AnimationPlayer

func _ready():
	current_world.connect("world_changed", self, "handle_world_change")

func handle_world_change(current_world_name : String, go_back_scene : bool):
	var next_world_name : String
	var last_world_name : String
	var selected_world : String
	
	match current_world_name:
		"Scene_One":
			next_world_name = "Scene_Two"
		"Scene Two":
			#next_world_name = "Scene_Three"
			last_world_name = "Scene_One"
		_:
			return
	
	if go_back_scene:
		selected_world = last_world_name
	else:
		selected_world = next_world_name
	
	next_world = load("res://scenes/" + selected_world + ".tscn").instance()
	next_world.z_index = -10
	add_child(next_world)
	animation_player.play("fade_in")
	next_world.connect("world_changed", self, "handle_world_change")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			print("fade in")
			current_world.queue_free()
			current_world = next_world
			current_world.z_index = 0
			next_world = null
			animation_player.play("fade_out")
			
