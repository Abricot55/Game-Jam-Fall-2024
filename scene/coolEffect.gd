extends Node2D

# Number of particles to spawn at a time
var particles_per_frame = 1

# Path to the SandParticle scene
const SandParticleScene = preload("res://scene/sandwind.tscn")

func _process(delta):
	for i in range(particles_per_frame):
		spawn_particle()

func spawn_particle():
	var particle = SandParticleScene.instantiate()
	add_child(particle)
	# Set random starting positions for particles
	particle.position = Vector2(randf() * get_viewport().size.x, get_viewport().size.y)  # Spawn at random X position at the top
