extends Node2D

const PLAYER_SCENE = preload("res://Scenes/Player.tscn")

var next_scene : String = "res://Scenes/Levels/TutorialIsland.tscn"
var player_spawn_location = null
var player_spawn_dir = null


func load_initial_game():
	#Add all of the other peers' player objects to the SceneManager
	for peer_id in Network.connected_peer_ids:
		if Network.peer_id != peer_id:
			add_new_player(peer_id)
	
	#After all players are added, reset the UI to load the actual game level
	$LoginScene.visible = false
	$CurrentScene.visible = true
	$DialogueMenu.visible = true
	$ScreenTransition.visible = true
	
	#Transition to the new scene
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
	
	#Change scene the local player is in - and make sure all other players update their objects
	Network.loaded_scene = next_scene
	Utility.get_player().current_level_name = next_scene
	
	#Re-spawn all players
	for child in $PlayerList.get_children():
		#Set the spawn for the local player object
		child.set_spawn(player_spawn_location, player_spawn_dir)
		#Set the spawn (and new scene) for the remote player object
		if child.name == str(Network.peer_id):
			child.rpc("player_changed_scene", next_scene, player_spawn_location, player_spawn_dir)
	
	#Update the visibility of each player character based on what scene they are in
	update_visibility_of_players()
	
	$ScreenTransition/AnimationPlayer.play("FadeFromBlack")


func update_visibility_of_players():
	for child in $PlayerList.get_children():
		if child.current_level_name == Network.loaded_scene:
			child.set_visibility(true)
		else:
			child.set_visibility(false)


func add_new_player(peer_id: int):
	var peer_player = PLAYER_SCENE.instantiate()
	
	#Make sure to set the authority so the on_ready function can use it to set the name 
	peer_player.set_multiplayer_authority(peer_id)
	
	$PlayerList.add_child(peer_player)
	
	#Set the initial spawn location
	peer_player.set_spawn(Vector2(0, 0), Vector2(0, 1))
	peer_player.current_level_name = next_scene
