extends Node


func get_player():
	#get_children().back() gets the Player from the NEWEST scene instead of the one we are transitioning from
	return get_node("/root/SceneManager/PlayerList").get_node(str(Network.peer_id))
