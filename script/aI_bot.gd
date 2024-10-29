extends Node3D

@export var speed: float = 15.0
@export var rotation_speed: float = 5.0

@onready var character = $CharacterBody3D
var cannot_move = false
var just_stopped = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


var number_scrap = 5
var team = 0
signal attack
signal died

var ATTACK_RANGE = 5
var realposition


var FRONT_ATTACK_RANGE = 5

func _process(delta):
	realposition = character.global_transform.origin

func get_num_scrap():
	return number_scrap

func add_scrap():
	number_scrap += 1
	
func remove_a_scrap():
	number_scrap -= 1
	if number_scrap <= 0:
		emit_signal("died")

func attacked():
	if number_scrap < 5:
		number_scrap -= 2
	elif number_scrap < 10:
		number_scrap -= 3
	elif number_scrap < 15:
		number_scrap -= 4
	elif number_scrap < 20:
		number_scrap -= 5
	if number_scrap <= 0:
		emit_signal("died")
		
func set_team(num : int):
	team = num

func get_team():
	return team

func in_attack_area(position_other : Vector3):
	var distance = global_transform.origin.distance_to(position_other)
	if distance <= ATTACK_RANGE:  # Check distance
		return true
	return false
