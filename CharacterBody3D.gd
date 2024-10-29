extends CharacterBody3D

@export var speed: float = 15.0
@export var rotation_speed: float = 5.0

@onready var animation = $robot/AnimationPlayer

var cannot_move = false
var just_stopped = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var number_scrap = 5
var team = 0
signal attack


var ATTACK_RANGE = 5

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity*delta
	else :
		velocity.y = 0

	var input_direction = Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	# For the attack animation
	if Input.is_action_just_pressed("space"):
		cannot_move = true
		animation.play("attackspinlonghands")
		emit_signal("attack")
		
	if Input.is_action_just_pressed("h"):
		cannot_move = true
		animation.play("hello")

	# For the movement
	if input_direction != Vector3.ZERO:
		velocity.x = input_direction.x * speed
		velocity.z = input_direction.z * speed
		var target_rotation = 0
		if velocity.x < 0:
			target_rotation = input_direction.angle_to(Vector3.FORWARD)
		else:
			target_rotation = -input_direction.angle_to(Vector3.FORWARD)
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
		
		if !animation.is_playing():
			cannot_move = false
			animation.play("walking")
		if not cannot_move:
			just_stopped = true

	if not cannot_move:
			move_and_slide()

	if input_direction == Vector3.ZERO:
		if not cannot_move:
			if just_stopped:
				animation.play("walkingstop")
				just_stopped = false
			elif !animation.is_playing():
				animation.play("iddle")
		velocity = Vector3(0, velocity.y, 0)  

func get_num_scrap():
	return number_scrap

func add_scrap():
	number_scrap += 1
	
func remove_a_scrap():
	number_scrap -= 1

func attacked():
	if number_scrap < 5:
		number_scrap -= 2
	elif number_scrap < 10:
		number_scrap -= 3
	elif number_scrap < 15:
		number_scrap -= 4
	elif number_scrap < 20:
		number_scrap -= 5
		
func set_team(num : int):
	team = num

func get_team():
	return team

func in_attack_area(position_other : Vector3):
	var distance = global_transform.origin.distance_to(position_other)
	if distance <= ATTACK_RANGE:  # Check distance
		return true
	return false
	
