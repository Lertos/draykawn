extends Node2D

const PLAYER_SCENE = preload("res://Scenes/Player.tscn")

var next_scene : String = "res://Scenes/Levels/TutorialIsland.tscn"
var player_spawn_location = null
var player_spawn_dir = null


func add_new_player():
	var peer_player = PLAYER_SCENE.instantiate()

	$PlayerList.add_child(peer_player)


func load_initial_game():
	add_new_player()
	
	#After the player is added, reset the UI to load the actual game level
	$LoginScene.visible = false
	$CurrentScene.visible = true
	$DialogueMenu.visible = true
	$ScreenTransition.visible = true
	
	#Transition to the new scene
	#TODO: Set the initial spawn loc / dir from the player.dat file
	transition_to_scene("res://Scenes/Levels/TutorialIsland.tscn", Vector2(0, 0), Vector2(0, 1))


func transition_to_scene(new_scene: String, spawn_location: Vector2, spawn_dir: Vector2):
	next_scene = new_scene
	player_spawn_location = spawn_location
	player_spawn_dir = spawn_dir
	
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")


func finished_fading():
	#Remove any existing level scenes
	for child in $CurrentScene.get_children():
		child.queue_free()

	#Load the next scene, adding it to the SceneManager
	$CurrentScene.add_child(load(next_scene).instantiate())
	
	#Change scene the player is in
	#TODO: Need to load the level contents from the file here (like NPC's locations, story beats, etc)
	var player = Utility.get_player()
	
	player.current_level_name = next_scene
	player.set_spawn(player_spawn_location, player_spawn_dir)

	$ScreenTransition/AnimationPlayer.play("FadeFromBlack")
