extends RigidBody3D

class_name Debris

static var this_scene = preload("res://scene/debris/nut_debris.tscn")

static func summon_at_random(parent: Node3D, pos: Vector3, num: int) -> void:
	print(pos, num)
	for i in range(num):
		var new_debris = this_scene.instantiate() as Debris
		parent.add_child(new_debris)
		
		new_debris.global_position = pos
		var dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * 10
		new_debris.apply_central_impulse(Vector3(dir.x, 10, dir.y))
		

func _on_area_3d_area_entered(area: Area3D) -> void:
	# check if player
	var area_parent = area.get_parent() # could be characterbody3d
	if area_parent == null:
		return
		
	var second_parent = area_parent.get_parent() # could be robot or aibot
	
	if second_parent is Robot:
		second_parent.add_scrap()
		self.queue_free()
	elif second_parent is AIBot:
		second_parent.add_scrap()
		self.queue_free()
