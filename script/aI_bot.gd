extends Node3D

class_name AIBot

@export var speed: float = 15.0
@export var rotation_speed: float = 5.0

@onready var character = $CharacterBody3D
@onready var drop_position = $CharacterBody3D/DropPosition

var cannot_move = false
var just_stopped = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var otherPlayers = []

var number_scrap = 15
var team = 0
signal died
signal scrap_changed

var ATTACK_RANGE = 5
var realposition

var shield = false
var att_freeze = false
var frozen = false
var FRONT_ATTACK_RANGE = 5

func _ready():
	emit_signal("scrap_changed")
	
func _process(_delta):
	realposition = character.global_transform.origin

func get_num_scrap():
	return number_scrap

func add_scrap():
	number_scrap += 1
	emit_signal("scrap_changed")
	if number_scrap > 10 and GameData.game_mode == "BANK":
		character.cash_in = true
		character.bank_location = GameData.banks[team].position
	elif number_scrap > 10 and GameData.game_mode == "POOR":
		var nums = [0,1,2,3]
		nums.remove_at(team)
		character.cash_in = true
		character.bank_location = GameData.banks[nums[randi()%nums.size()]].position
	
func remove_a_scrap():
	number_scrap -= 1
	emit_signal("scrap_changed")
	if number_scrap == 9:
		character.cash_in = false
	if number_scrap <= 0:
		emit_signal("died")

func attacked():
	if not shield:
		var scene = self.get_parent_node_3d()
		var drop_pos = drop_position.global_position
		character.knockback()
		if number_scrap < 5:
			number_scrap -= 2
			Debris.summon_at_random(scene, drop_pos, 2)
		elif number_scrap < 10:
			number_scrap -= 3
			Debris.summon_at_random(scene, drop_pos, 3)
		elif number_scrap < 15:
			number_scrap -= 4
			Debris.summon_at_random(scene, drop_pos, 4)
		elif number_scrap < 20:
			number_scrap -= 5
			Debris.summon_at_random(scene, drop_pos, 5)
		else:
			number_scrap -= 6
			Debris.summon_at_random(scene, drop_pos, 6)
		if number_scrap <= 9:
			character.cash_in = false
		emit_signal("scrap_changed")
		if number_scrap <= 0:
			emit_signal("died")
			character.velocity = Vector3(0,0,0)
			character.knockback_direction = Vector3(0,0,0)
			character.knockback_timer = 0
		
func set_team(num : int):
	team = num

func get_team():
	return team

func in_attack_area(position_other : Vector3):
	var distance = character.global_transform.origin.distance_to(position_other)
	if distance <= ATTACK_RANGE+2:  # Check distance
		return true
	return false
	
func activate_super_speed():
		var speedTimer = Timer.new()
		speedTimer.wait_time = 6
		speedTimer.one_shot = true
		speedTimer.connect("timeout",Callable(self,"_on_speed_timeout"))
		character.speed = 50
		add_child(speedTimer)
		speedTimer.start()

func _on_speed_timeout():
	character.speed = 25

func activate_shield():
	var speedTimer = Timer.new()
	speedTimer.wait_time = 6
	speedTimer.one_shot = true
	speedTimer.connect("timeout",Callable(self,"on_shield_timeout").bind(speedTimer))
	shield = true
	$CharacterBody3D/shield_mesh.visible = true
	add_child(speedTimer)
	speedTimer.start()

func on_shield_timeout(timer):
	shield = false
	$CharacterBody3D/shield_mesh.visible = false
	remove_child(timer)

func activate_freeze():
	att_freeze = true

func is_frozen():
	character.CANT_MOVE = true
	var speedTimer = Timer.new()
	speedTimer.wait_time = 3
	speedTimer.one_shot = true
	speedTimer.connect("timeout",Callable(self,"on_freeze_timeout").bind(speedTimer))
	$CharacterBody3D/freeze_mesh.visible = true
	add_child(speedTimer)
	speedTimer.start()
	
func on_freeze_timeout(timer):
	$CharacterBody3D/freeze_mesh.visible = false
	remove_child(timer)
	character.CANT_MOVE = false
