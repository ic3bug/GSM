extends RayCast3D

var t : float = 0.0

func _physics_process(delta):
	t += delta
	if t >= delta * 2: 
		queue_free()
	if !is_colliding(): return
	var collider = get_collider()
	if collider is CharacterBody3D:
		collider.velocity += (collider.global_transform.origin - get_collision_point()).normalized()
