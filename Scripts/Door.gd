extends Area2D

@onready var anim_player = $AnimationPlayer

@export_file var next_scene_path = ""

@export var spawn_location : Vector2 = Vector2(0, 0)
@export var spawn_dir : Vector2 = Vector2(0, 0)

var player_entered : bool = false


func _ready():
	Utility.get_player().signal_entering_door.connect(play_open_door)
	
	
func play_open_door():
	if player_entered:
		anim_player.play("open_door")


func play_close_door():
	if player_entered:
		anim_player.play("close_door")


func transition_to_scene():
	if player_entered:
		get_node(NodePath("/root/SceneManager")).transition_to_scene(next_scene_path, spawn_location, spawn_dir)


func on_body_entered(_body):
	player_entered = true


func on_body_exited(_body):
	player_entered = false
