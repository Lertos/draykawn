extends Node2D

const PORT = 9999
const SERVER_IP = "localhost"


func on_host_pressed():
	Network.peer = ENetMultiplayerPeer.new()
	
	Network.connected_peer_ids.append(1)
	
	multiplayer.peer_connected.connect(self.peer_connected)
	
	Network.peer.create_server(PORT)
	multiplayer.multiplayer_peer = Network.peer
	Network.peer_id = multiplayer.get_unique_id()
	
	print("DEBUG: Host ID: " + str(Network.peer_id))
	
	get_parent().add_new_player(1)
	get_parent().load_initial_game()


func peer_connected(id):
	#When a new client joins, add them to all the other clients
	rpc("add_new_client_to_scene", id)
	
	#Now send all existing peers to the new client and join the game
	rpc_id(id, "add_connected_peers_then_join", Network.connected_peer_ids)
	
	#Add the new client and peer ID to the server instance
	Network.connected_peer_ids.append(id)
	get_parent().add_new_player(id)


func on_join_pressed():
	Network.peer = ENetMultiplayerPeer.new()
	
	Network.peer.create_client(SERVER_IP, PORT)
	multiplayer.multiplayer_peer = Network.peer
	Network.peer_id = multiplayer.get_unique_id()
	
	print("DEBUG: Client ID: " + str(Network.peer_id))


@rpc
func add_new_client_to_scene(id):
	Network.connected_peer_ids.append(id)
	get_parent().add_new_player(id)


@rpc
func add_connected_peers_then_join(peer_ids):
	for peer_id in peer_ids:
		Network.connected_peer_ids.append(peer_id)
	get_parent().load_initial_game()
