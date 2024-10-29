extends CharacterBody3D

@export var speed: float = 5.0  # Speed of movement
@export var change_direction_time: float = 2.0  # Time before changing direction
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")  # Gravity value

var direction: Vector3 = Vector3.ZERO
var timer: Timer

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
	move_and_slide()
