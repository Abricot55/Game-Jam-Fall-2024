extends CharacterBody3D

@export var speed: float = 15.0  # Speed of movement
@export var change_direction_time: float = 4  # Time before changing direction
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")  # Gravity value
@onready var animation = $robot/AnimationPlayer

var direction: Vector3 = Vector3.ZERO
var timer: Timer
var knockback_direction
var knockback_duration = 1
var knockback_timer = 0
var cannot_move = false

var bankTimer:Timer
var whichBot = 0
var destination = Vector3(0,0,0)

var dash_duration = 0.05
var dash_timer = 0

var ATTACK_RANGE = 5
var gamestyle = 0

var cash_in = false
var bank_location = Vector3(0,0,0)
var can_put_in = true

signal attack
signal died
signal banked

func _ready() -> void:
	gamestyle = randi() % 3
	print(gamestyle)
	timer = Timer.new()
	timer.wait_time = change_direction_time
	bankTimer = Timer.new()
	bankTimer.wait_time = 0.5
	bankTimer.connect("timeout",Callable(self,"_on_bank_timeout"))
	add_child(bankTimer)
	timer.connect("timeout",Callable(self,"_on_Timer_timeout"))
	add_child(timer)
	timer.start()

func _on_Timer_timeout() -> void:
	dash_timer = dash_duration


func _process(delta: float) -> void:

	if not is_on_floor():
		velocity.y -= gravity * delta
		dash_duration = 0
	else:
		velocity.y = 0 
		dash_duration = 0.05
		if !cash_in:
			match gamestyle:
				0: aggressiveGuy(delta)
				1: assassin(delta)
				2: random_attack(delta)
		else:
			go_cash_in(delta)
			
		var target_rotation = 0
		if velocity.x < 0:
			target_rotation = velocity.angle_to(Vector3.FORWARD)
		else:
			target_rotation = -velocity.angle_to(Vector3.FORWARD)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5 * delta)
		if knockback_timer > 0:
			velocity = knockback_direction
			knockback_timer -= delta
			move_and_slide()
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

func go_to_most_gear_ennemy():
	var max
	for i in GameData.players:
		if i != null:
			if max == null or i.number_scrap > max.number_scrap:
				max = i
	if max != null:
		if max.get_child(0).position == position:
			var s = all_dudes()
			if s !=null and s.size > 1:
				go_to_least_gear_ennemy()
			if s == null:
				direction = bank_location
		else:
			destination = max.get_child(0).position
	else:
		destination = Vector3(0,0,0)

func find_random_dud():
	var dudes = all_dudes()
	if dudes == null:
		return null
	return dudes[randi() % dudes.size()]

func all_dudes():
	var dudes = []
	for i in dudes:
		if i != null and i.get_child(0).position != position:
			dudes.append(i)	
	if dudes == []:
		return null
	return dudes

func aggressiveGuy(delta):
	go_to_most_gear_ennemy()
	do_movement_thing(delta)
	
func assassin(delta):
	go_to_least_gear_ennemy()
	do_movement_thing(delta)
	

func go_to_least_gear_ennemy():
	var min
	for i in GameData.players:
		if i != null:
			if min == null or i.number_scrap <= min.number_scrap:
				min = i
	if min != null:
		if min.get_child(0).position == position:
			go_to_most_gear_ennemy()
		else:
			destination = min.get_child(0).position
	else:
		destination = Vector3(0,0,0)

func do_movement_thing(delta):
	var direction = (destination - global_transform.origin).normalized()
	velocity = direction * speed
	if !animation.is_playing():
		animation.play("walking")
	if global_transform.origin.distance_to(destination) < ATTACK_RANGE:
		emit_signal("attack")
		animation.play("attackspinlonghands")
		destination = Vector3(0,0,0)
	if dash_timer > 0:
		velocity = velocity*10
		dash_timer -= delta
		move_and_slide()
		if dash_timer <=0 :
			animation.play("walkingstop")

func go_cash_in(delta):
	var direction = (bank_location - global_transform.origin).normalized()
	velocity = direction * speed
	if !animation.is_playing():
		animation.play("walking")
	if global_transform.origin.distance_to(bank_location) < 10:
		if can_put_in:
			emit_signal("banked")
			animation.play("attackwithhand")
			destination = Vector3(0,0,0)
			can_put_in = false
			bankTimer.start()
	if dash_timer > 0:
		velocity = velocity*10
		dash_timer -= delta
		move_and_slide()
		if dash_timer <=0 :
			animation.play("walkingstop")
			
func _on_bank_timeout():
	can_put_in = true

func random_attack(delta):
	if destination == Vector3(0,0,0) or destination == bank_location:
		var d = find_random_dud()
		if d == null:
			destination = bank_location
		else:
			destination = d.get_child(0).position
	do_movement_thing(delta)
