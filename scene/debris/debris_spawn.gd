extends Node3D

@export var max_debris: int = 5
@export var spawn_rate: float = 2.0

@export_category("Spawn Position")
@export var spawn_min: Vector3 = Vector3.ONE
@export var spawn_max: Vector3 = Vector3.ONE

var debris = preload("res://scene/debris/nut_debris.tscn")
var spawn_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_rate
	spawn_timer.connect("timeout", spawn_timer_timeout)
	self.add_child(spawn_timer)
	spawn_timer.start()
	
func spawn_timer_timeout() -> void:
	var current_debris = count_debris_children()
	if current_debris >= max_debris:
		return
	
	var x_pos = randf_range(spawn_min.x, spawn_max.x)
	var y_pos = randf_range(spawn_min.y, spawn_max.y)
	var z_pos = randf_range(spawn_min.z, spawn_max.z)
	
	spawn_debris_at(Vector3(x_pos, y_pos, z_pos))
	
func count_debris_children() -> int:
	var count = 0
	for n in self.get_children(true):
		if n is Debris:
			count += 1
	
	return count
	
func spawn_debris_at(pos: Vector3) -> void:
	var new_debris = debris.instantiate() as Debris
	self.add_child(new_debris)
	
	new_debris.global_position = pos
	
