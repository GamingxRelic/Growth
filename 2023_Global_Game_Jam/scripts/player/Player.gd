extends KinematicBody2D

# Sprite variable

onready var sprite = get_node("Sprite") 

# Horizontal variable
export var movement_speed : float
var horizontal_input : float
var running_friction : float = 0.7
var stopping_friction : float = 0.1
var air_friction : float = 0.7

# Jumping variables
export var max_velocity_y : float
export var jump_height : float
export var super_jump_height : float
export var gravity : int
var jumping = false
var super_jumping = false
var falling = false

# Dash variables
export var dash_speed : float
export var dash_duration : float
export var dash_cooldown : float
onready var dash = $Dash

# Animation variables
onready var animation_player = $AnimationPlayer
var facing = 1

# Player velocity 
var velocity : Vector2 = Vector2()

# Grapple hook variables
var hook_pos = Vector2()
var hooked = false
var rope_length = 200
var current_rope_length

func _ready():
	current_rope_length = rope_length

func _physics_process(delta):
	# Player velocity.y 
	if velocity.y > max_velocity_y:
		velocity.y = max_velocity_y
	
#	if jumping and velocity.y == gravity:
#		velocity.y = 0
#		gravity = 0
	
	# Horizontal Movement
	horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	# Dash
	if Input.is_action_just_pressed("dash") and dash.can_dash() and horizontal_input != 0 and !hooked:
		dash.start_dash(dash_duration, dash_cooldown, sprite)
	
	if is_on_floor():
		jumping = false
		super_jumping = false
		dash.dash_available
	
	var snap = Vector2.DOWN if !jumping else Vector2.ZERO
	#velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(60))
	
	# Jumping movement
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and !hooked:
		jump()
	elif Input.is_action_just_pressed("right_click") and is_on_floor() and !hooked:
		super_jump()
	
	# Set max velocity.y
	if velocity.y > max_velocity_y :
		velocity.y = max_velocity_y
		
	# Animation
	play_animation()
	
	# Grapple hook function
	
	hook()
	update()
	
	if hooked:
		
		if next_to_left_wall() and horizontal_input == -1:
			velocity.x = -10
			velocity.y = -25
		elif next_to_right_wall() and horizontal_input == 1:
			velocity.x = 10
			velocity.y = -25
		else:
			velocity.y += gravity
			swing()
		velocity = move_and_slide(velocity, Vector2.UP)
		return
	
	if !is_on_floor() and !hooked:
		falling = true
	else:
		falling = false
	
	if dash.is_dashing():
		velocity.x = dash_speed*facing
		velocity.y = 0
	# Walk
	elif !hooked: 
		if horizontal_input != 0:
				
			velocity.x += (horizontal_input * movement_speed)
	
	if !dash.is_dashing():
		velocity.y += gravity
	
	if is_on_floor():
		if horizontal_input != 0:
			velocity.x *= running_friction
		else:
			velocity.x *= stopping_friction
	else:
		velocity.x *= air_friction
	
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(60))
	
	
# Jump Function
func jump():
	velocity.y = -jump_height
	jumping = true
	
func super_jump():
	velocity.y = -super_jump_height
	super_jumping = true
	
func play_animation(): 
	if horizontal_input == 0 and !jumping and !falling:
		if facing == 1 and animation_player.get_current_animation() != "player_jump_right":
			animation_player.play("player_idle_right")
		elif facing == -1 and !dash.is_dashing():
			animation_player.play("player_idle_left")
	elif horizontal_input > 0 and animation_player.get_current_animation() != "player_jump_right":
		animation_player.play("player_limp_right")
		if !dash.is_dashing():
			facing = 1
	elif horizontal_input < 0:
		animation_player.play("player_limp_left")
		if !dash.is_dashing():
			facing = -1
			
	if dash.is_dashing():
		if facing == 1:
			animation_player.play("player_dash_right")
		elif facing == -1:
			animation_player.play("player_dash_left")
			
	if Input.is_action_just_pressed("ui_up") and jumping and is_on_floor() and !hooked:
		if facing == 1:
			animation_player.play("player_jump_right")
		elif facing == -1:
			animation_player.play("player_jump_left")

	if falling and !dash.is_dashing():
		if facing == 1:
			animation_player.play("player_fall_right")
		elif facing == -1:
			animation_player.play("player_fall_left")
		

# Grapple Stuff
func swing():
	var radius = global_position - hook_pos # points away from center
	if velocity.length() < 0.01 or radius.length() < 10: return
	var angle = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var rad_vel = cos(angle) * velocity.length()
	velocity += radius.normalized() * -rad_vel
	#print (velocity)
	# Hacky way to fix gradual lengthening
	if global_position.distance_to(hook_pos) > current_rope_length:
		global_position = hook_pos + radius.normalized() * current_rope_length

func hook():
	$Raycasts.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("left_click"):
		hook_pos = get_hook_pos()
		if hook_pos:
			hooked = true
			current_rope_length = global_position.distance_to(hook_pos)
	elif Input.is_action_just_released("left_click"):
		hooked = false

func get_hook_pos():
	for raycast in $Raycasts.get_children():
		if raycast.is_colliding() and raycast.get_collider().is_in_group("can_hook"):
			return raycast.get_collision_point()

func _draw():
	if hooked:
		draw_line($Raycasts.position, to_local(hook_pos), Color(0.40, 0.27, 0.03), 2, true)
	else:
		return

func next_to_right_wall():
	#print("next_to_right")
	return ($Wall_Check_Right_Top.is_colliding() and $Wall_Check_Right_Top.get_collider().is_in_group("ground")) \
	or ($Wall_Check_Right_Center.is_colliding() and $Wall_Check_Right_Center.get_collider().is_in_group("ground")) \
	or ($Wall_Check_Right_Bottom.is_colliding() and $Wall_Check_Right_Bottom.get_collider().is_in_group("ground"))
func next_to_left_wall():
	#print("next_to_left")
	return ($Wall_Check_Left_Top.is_colliding() and $Wall_Check_Left_Top.get_collider().is_in_group("ground")) \
	or ($Wall_Check_Left_Center.is_colliding() and $Wall_Check_Left_Center.get_collider().is_in_group("ground")) \
	or ($Wall_Check_Left_Bottom.is_colliding() and $Wall_Check_Left_Bottom.get_collider().is_in_group("ground"))


