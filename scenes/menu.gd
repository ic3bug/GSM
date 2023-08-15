# Main menu
extends Control

func _on_create_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Game.PORT)
	multiplayer.multiplayer_peer = peer
	Game.load_map()

func _on_connect_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", Game.PORT)
	multiplayer.multiplayer_peer = peer
	Game.load_map()
