extends RayCast3D

func _process(_delta):
	if !is_colliding(): return
	var collider = get_collider()
	if collider is CharacterBody3D:
		collider.velocity += Vector3.UP * 10.0
