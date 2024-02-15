# Autoloaded script/singleton
# Added to the root location
# Manages game states
extends Node

const PORT : int = 1337

@onready var main : Node = get_tree().root.get_node("Main")
@onready var players : Node = main.get_node("Players")

var menu : Control = null
var map : Node = null

func _ready():
	menu = preload("res://scenes/menu.tscn").instantiate()
	main.add_child(menu)
	
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(remove_player)

func load_map():
	# Free previously loaded maps and menus
	remove_stuff()
	
	# Spawn map
	map = preload("res://scenes/map.tscn").instantiate()
	main.add_child(map)
	
	# Spawn player
	spawn_player(multiplayer.get_unique_id())

func spawn_player(id: int):
	var player = preload("res://scenes/player.tscn").instantiate()
	player.peer_id = id
	players.add_child(player, true)
	player.global_transform.origin = Vector3.UP

func remove_player(id: int):
	if not players.has_node(str(id)):
		return
	players.get_node(str(id)).queue_free()

func remove_stuff():
	if map != null:
		map.queue_free()
	if menu != null:
		menu.queue_free()
