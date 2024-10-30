extends CharacterBody3D

@export var speed: float = 15.0
@export var rotation_speed: float = 5.0

@onready var animation = $robot/AnimationPlayer

var cannot_move = false
var just_stopped = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal attack
signal died

var dash_duration = 0.05
var dash_timer = 0

var ATTACK_RANGE = 5

var knockback_direction
var knockback_duration = 1
var knockback_timer = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity*delta
		dash_duration = 0
	else :
		velocity.y = 0
		dash_duration = 0.05

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
	
	if Input.is_action_just_pressed("shift"):
		dash_timer = dash_duration
		
	if dash_timer > 0:
		velocity = velocity*30
		dash_timer -= delta
		move_and_slide()
		if dash_timer <=0 :
			cannot_move = true
			animation.play("walkingstop")

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
	if knockback_timer > 0:
		velocity = knockback_direction
		knockback_timer -= delta
		move_and_slide()
	if position.y < -15:
		emit_signal("died")

func knockback():
	var random_x = randf_range(-1.0, 1.0)
	var random_y = randf_range(0, 0)
	var random_z = randf_range(-1.0, 1.0)
	
	# Crée un vecteur avec ces valeurs
	var random_vector = Vector3(random_x, random_y, random_z)
	
	# Normalise le vecteur pour qu'il ait une longueur de 1
	knockback_direction = random_vector*30
	knockback_timer = knockback_duration
