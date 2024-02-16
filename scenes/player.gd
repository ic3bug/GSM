extends CharacterBody3D

# Movement constants
const GRAVITY : float = 30.0
const MAX_SPEED : float = 15.0
const JUMP_FORCE : float = 10.0
const ACCELERATION : float = 5.0

# Mouse
@export var mouse_sensitivity : float = 3.0

# Peer identification
@export var peer_id : int : 
	set(value):
		peer_id = value
		name = str(peer_id)
		$Label3D.text = str(peer_id)
		set_multiplayer_authority(peer_id)

@export var sync_position : Vector3
@export var sync_rotation : Vector3
@export var sync_look : float

func _ready():
	# Capture the mouse on player spawn
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Set the camera as the current camera
	%Camera3D.current = peer_id == multiplayer.get_unique_id()
	# Set process functions for current player
	var is_local = is_multiplayer_authority()
	set_process_input(is_local)
	set_process(is_local)
	# Mesh rendering mode
	$Model/Skeleton3D/Mesh.cast_shadow = 3 if is_local else 1

func _process(_delta):
	# Handle mouse capture
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	sync_movement(delta)
	process_movement(delta)
	process_fire()

func process_movement(delta : float):
	if not is_multiplayer_authority(): return
	
	# Add the gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle Jump
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Get the input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Calculate velocity without affecting the up-and-down vector
	velocity.x = lerp(velocity.x, direction.x * MAX_SPEED, delta * ACCELERATION)
	velocity.z = lerp(velocity.z, direction.z * MAX_SPEED, delta * ACCELERATION)

	# Godot's movement and collision detection function
	move_and_slide()
	
	# Synchronize position and rotation
	sync_position = position
	sync_rotation = rotation

# Interpolate peer movement and rotation
func sync_movement(delta):
	if is_multiplayer_authority(): return
	position = lerp(position, sync_position, delta * 12.0)
	rotation.y = lerp_angle(rotation.y, sync_rotation.y, delta * 12.0)
	$Model/AnimationTree.set("parameters/look/blend_amount", sync_look)
	$Head.rotation.x = sync_look

func process_fire():
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("player_fire"):
		rpc.call("fire_ray")

@rpc("call_local")
func fire_ray():
	var ray = preload("res://scenes/ray.tscn").instantiate()
	ray.global_transform = $Head.global_transform
	Game.main.add_child(ray, true)

func _input(event):
	# If mouse is visible do nothing
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	if event is InputEventMouseMotion:
		# Handle body rotation
		rotation.y -= event.relative.x * 0.001 * mouse_sensitivity
		# Handle head rotation
		$Head.rotation.x -= event.relative.y * 0.001 * mouse_sensitivity
		$Head.rotation.x = clamp($Head.rotation.x, -1.5, 1.5)
		$Model/AnimationTree.set("parameters/look/blend_amount", $Head.rotation.x)
		sync_look = $Head.rotation.x
