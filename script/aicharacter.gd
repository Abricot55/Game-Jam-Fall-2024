extends CharacterBody3D

@export var speed: float = 5.0  # Speed of movement
@export var change_direction_time: float = 2.0  # Time before changing direction
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")  # Gravity value

var direction: Vector3 = Vector3.ZERO
var timer: Timer
var knockback_direction
var knockback_duration = 1
var knockback_timer = 0


func _ready() -> void:

	timer = Timer.new()
	timer.wait_time = change_direction_time
	timer.connect("timeout",Callable(self,"_on_Timer_timeout"))
	add_child(timer)
	timer.start()

	change_direction()

func _on_Timer_timeout() -> void:
	change_direction()

func change_direction() -> void:
	direction = Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1)
	).normalized()

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0 

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed 
		velocity.z = direction.z * speed
	if knockback_timer > 0:
		velocity = knockback_direction
		knockback_timer -= delta
	move_and_slide()

func knockback():
	var random_x = randf_range(-1.0, 1.0)
	var random_y = randf_range(0, 0.5)
	var random_z = randf_range(-1.0, 1.0)
	
	# Crée un vecteur avec ces valeurs
	var random_vector = Vector3(random_x, random_y, random_z)
	
	# Normalise le vecteur pour qu'il ait une longueur de 1
	knockback_direction = random_vector*30
	knockback_timer = knockback_duration
