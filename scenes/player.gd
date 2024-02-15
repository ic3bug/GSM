extends CharacterBody3D

# Movement constants
const GRAVITY = 30.0
const SPEED = 15.0
const JUMP_VELOCITY = 10.0

# Mouse
@export var mouse_sensitivity : float = 3.0

# Peer identification
@export var peer_id : int : 
	set(value):
		peer_id = value
		name = str(peer_id)
		$Label3D.text = str(peer_id)
		set_multiplayer_authority(peer_id)

func _ready():
	# Capture the mouse on player spawn
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Set the camera as the current camera
	$Camera3D.current = peer_id == multiplayer.get_unique_id()
	# Set process functions for current player
	var is_local = is_multiplayer_authority()
	set_process_input(is_local)
	set_physics_process(is_local)
	set_process(is_local)

func _process(_delta):
	# Handle mouse capture
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle Jump
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Godot's movement and collision detection function
	move_and_slide()

func _input(event):
	# If mouse is visible do nothing
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	# Handle body rotation
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * 0.001 * mouse_sensitivity
		$Camera3D.rotation.x -= event.relative.y * 0.001 * mouse_sensitivity
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -1.5, 1.5)
