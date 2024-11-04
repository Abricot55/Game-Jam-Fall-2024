extends Node2D

# Speed of the particle
var speed = Vector2(0, 0)
# Wind strength in the horizontal direction
var wind_strength = 300
# Gravity force applied to the particle
var gravity = -200
# Lifetime of the particle
var lifetime = 5.0
var timer = 0.0

func _ready():
	randomize()  # Randomize the initial horizontal speed
	speed.x = randf_range(-wind_strength, wind_strength)  # Randomize the wind direction

func _process(delta):
	apply_gravity(delta)
	position += speed * delta  # Update the position based on speed
	timer += delta

	# Remove particle after its lifetime
	if timer > lifetime:
		queue_free()  # Free the particle from memory

# Apply gravity to the particle
func apply_gravity(delta):
	speed.y += gravity * delta  # Gravity affects the Y-axis speed
