extends CharacterBody2D

signal signal_entering_door
signal signal_entered_door

enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDir { LEFT, RIGHT, UP, DOWN }

@onready var blocking_collision_ray : RayCast2D = $BlockingRayCast2D
@onready var door_collision_ray : RayCast2D = $DoorRayCast2D
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var anim_player = $Animator
@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

@export var WALK_SPEED = 4.0
@export var TILE_SIZE = 16

var player_state = PlayerState.IDLE
var dir_state = FacingDir.DOWN

#The scene/level the player is currently moving around in
var current_level_name : String = ""

var initial_pos = Vector2(0, 0)
var input_dir = Vector2(0, 1)

var stop_input : bool = false
var is_moving : bool = false
var entering_door : bool = false
var percent_moved_to_next_tile = 0.0


func _ready():
	set_collision_data()


#Dynamically set the positions/sizes of all objects pertaining to the tile size
func set_collision_data():
	var tile_position = Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)

	blocking_collision_ray.position = tile_position
	door_collision_ray.position = tile_position
	collision_shape.position = tile_position


func set_visibility(value: bool):
	$Sprite2D.visible = value


func set_spawn(spawn_location: Vector2, spawn_dir: Vector2):
	position = spawn_location
	set_input_dir(spawn_dir)
	set_visibility(true)
	
	reset_player_object()


func reset_player_object():
	percent_moved_to_next_tile = 0.0
	initial_pos = position
	
	stop_input = false
	entering_door = false
	is_moving = false
	anim_tree.active = true


func _physics_process(delta):
	#Always respect the global movement stop setting first
	if GlobalSettings.stop_movement:
		if percent_moved_to_next_tile != 0.0:
			move(delta)
			return
		else:
			#If the player input has stopped then set the player to IDLE
			change_state_idle()
		
	#If the player must stop input or is turning; ignore any other input
	if stop_input or player_state == PlayerState.TURNING:
		return
		
	#If the player is not moving, check for any input
	elif is_moving == false:
		process_player_input()
		
	#If the player is moving and there is input in a direction, move the player
	elif input_dir != Vector2.ZERO:
		change_state_walk()
		move(delta)
			
	#If nothing happens, then the player is idle
	else:
		change_state_idle()
		reset_player_object()


func process_player_input():
	get_player_input_dir()
	
	if input_dir != Vector2.ZERO:
		set_input_dir(input_dir)
		
		if need_to_turn():
			change_state_turn()
		else:
			initial_pos = position
			is_moving = true
	else:
		change_state_idle()


func set_input_dir(dir: Vector2):
	anim_tree.set("parameters/idle/blend_position", dir)
	anim_tree.set("parameters/walk/blend_position", dir)
	anim_tree.set("parameters/turn/blend_position", dir)


func get_player_input_dir():
	if input_dir.y == 0:
		input_dir.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if input_dir.x == 0:
		input_dir.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))


func need_to_turn():
	var new_dir
	
	if input_dir.x < 0:
		new_dir = FacingDir.LEFT
	elif input_dir.x > 0:
		new_dir = FacingDir.RIGHT
	elif input_dir.y < 0:
		new_dir = FacingDir.UP
	elif input_dir.y > 0:
		new_dir = FacingDir.DOWN
	
	var needs_to_turn = dir_state != new_dir
	
	dir_state = new_dir
	return needs_to_turn


func finished_turning():
	player_state = PlayerState.IDLE


func start_entering_door():
	emit_signal("signal_entering_door")


func finished_disappearing():
	emit_signal("signal_entered_door")


func move(delta):
	var desired_step : Vector2 = input_dir * TILE_SIZE / 2

	check_for_collisions(blocking_collision_ray, desired_step)
	check_for_collisions(door_collision_ray, desired_step)
	
	#If entering a door
	if door_collision_ray.is_colliding():
		#is_moving = false
		stop_input = true
		anim_tree.active = false

		#Only play the animation once when first entering the door
		if !entering_door:
			entering_door = true
			anim_player.play("disappear")
	#If movement is blocked due to collision
	elif !blocking_collision_ray.is_colliding():
		percent_moved_to_next_tile += WALK_SPEED * delta
		
		if percent_moved_to_next_tile >= 1.0:
			position = initial_pos + (TILE_SIZE * input_dir)
			reset_player_object()
		else:
			position = initial_pos + (TILE_SIZE * input_dir * percent_moved_to_next_tile)
	#If just sitting idle
	else:
		change_state_idle()
		reset_player_object()


func check_for_collisions(raycast, desired_step):
	raycast.target_position = desired_step
	raycast.force_raycast_update()


func change_state_idle():
	player_state = PlayerState.IDLE
	anim_state.travel("idle")


func change_state_walk():
	player_state = PlayerState.WALKING
	anim_state.travel("walk")


func change_state_turn():
	player_state = PlayerState.TURNING
	anim_state.travel("turn")
