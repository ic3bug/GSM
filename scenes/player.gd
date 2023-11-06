extends CharacterBody3D

const GRAVITY = 30.0
const SPEED = 15.0
const JUMP_VELOCITY = 10.0

# Peer id.
@export var peer_id : int : 
	set(value):
		peer_id = value
		name = str(peer_id)
		$Label3D.text = str(peer_id)
		set_multiplayer_authority(peer_id)

func _ready():
	# Set local camera.
	$Camera3D.current = peer_id == multiplayer.get_unique_id()
	# Set process functions for current player.
	var is_local = is_multiplayer_authority()
	set_process_input(is_local)
	set_physics_process(is_local)
	set_process(is_local)

func _process(_delta):
	# Handle mouse capture.
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle Jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	# Handle body rotation.
	if event is InputEventMouseMotion:
		rotation.y += event.relative.x * -0.001
