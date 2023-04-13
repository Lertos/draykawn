extends Node


func get_player():
	return get_node("/root/SceneManager/PlayerList").get_child(0)
