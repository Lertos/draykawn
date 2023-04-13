extends Area2D

@export_file var next_scene_path = ""

@export var spawn_location : Vector2 = Vector2(0, 0)
@export var spawn_dir : Vector2 = Vector2(0, 0)

var player_entered : bool = false


func _ready():
	Utility.get_player().signal_entering_door.connect(transition_to_scene)


func transition_to_scene():
	if player_entered:
		get_node(NodePath("/root/SceneManager")).transition_to_scene(next_scene_path, spawn_location, spawn_dir)


func on_body_entered(body):
	player_entered = true


func on_body_exited(body):
	player_entered = false
