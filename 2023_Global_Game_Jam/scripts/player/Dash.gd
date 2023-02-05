extends Node2D

onready var duration_timer = $DurationTimer
onready var cooldown_timer = $CooldownTimer
onready var ghost_timer = $GhostTimer
var ghost_scene = preload("res://scenes/player/Dash_Ghost.tscn")
#var sprite
var dash_available = true


func start_dash(duration, dash_cooldown, spr):
	#self.sprite = spr
	print("dash!")
	duration_timer.wait_time = duration
	duration_timer.start()
	dash_available = false
	
	#ghost_timer.start()
	#instance_ghost()
	
	cooldown_timer.wait_time = dash_cooldown

func instance_ghost():
	var ghost : Sprite = ghost_scene.instance()
	get_parent().get_parent().add_child(ghost)
	
	ghost.global_position = global_position
	ghost.texture = load("res://assets/player/player_dash.png")
	ghost.hframes = 2
	ghost.vframes = 1
	if get_parent().facing == 1:
		ghost.frame = 0
	else:
		ghost.frame = 1
	ghost.centered = false

func is_dashing():
	return !duration_timer.is_stopped()

func can_dash():
	return dash_available and cooldown_timer.is_stopped()

func _on_DurationTimer_timeout():
	cooldown_timer.start()
	ghost_timer.stop()

func _on_GhostTimer_timeout():
	instance_ghost()


func _on_CooldownTimer_timeout():
	dash_available = true
