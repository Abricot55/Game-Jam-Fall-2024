extends Node3D

@onready var bank = $Bank
@onready var player_infos = $PlayerInfo


var player_scene = preload("res://scene/robot_3d.tscn")
var ai_bot_scene = preload("res://scene/aI_bot.tscn")

var players = [null,null,null,null]
var gamemode = "BANK"
var numberplayer = 1
var colors = [Color(1,0,0),Color(0,1,0), Color(0,0,1), Color(1,1,0)]

func _ready():
	for i in range(0,numberplayer):
		var player = player_scene.instantiate()
		player.set_team(i)
		respawn(player)
		player.get_child(0).connect("attack",  Callable(self, "_on_player_attacked").bind(i))
		player.get_child(0).connect("died",  Callable(self, "_died").bind(i))
		#player.connect("died",  Callable(self, "_died").bind(i))
		player.get_child(0).get_child(2).get_active_material(0).albedo_color = colors[player.team]
		
	for i in range(0,4-numberplayer):
		var new_ai_bot = ai_bot_scene.instantiate()
		new_ai_bot.team = i + numberplayer
		respawn(new_ai_bot)
		print(new_ai_bot.get_child(0).get_child(2).get_active_material(0))
		new_ai_bot.connect("died", Callable(self,"_died").bind(new_ai_bot.team))
		new_ai_bot.get_child(0).get_child(new_ai_bot.team+1).visible = true

func _process(delta):
	if Input.is_action_just_pressed("z"):
		if players[0].get_child(0).global_transform.origin.distance_to(bank.global_transform.origin) < bank.scale.x+2:
			if players[0].get_num_scrap() > 1:
				players[0].remove_a_scrap()
				bank.add_scrap()
				player_infos.get_child(0).get_child(1).text = "scraps : "+ str(bank.number_scrap) 

func _on_player_attacked(player_id):
	for bot in players:
		if bot != null:
			if bot.team != player_id:
				if players[player_id].in_attack_area(bot.realposition):
					bot.attacked()

func _died(player_id):
	var person = players[player_id]
	players[player_id] = null
	remove_child(person)
	await get_tree().create_timer(3.0).timeout # Wait for 3 seconds
	respawn(person)

func respawn(person): 
	var respawn_positions = [Vector3(2, 10, 0), Vector3(5, 10, 0), Vector3(0, 10, 5), Vector3(-5, 10, 0)]
	person.get_child(0).position = respawn_positions[randi() % respawn_positions.size()]
	players[person.team] = person
	add_child(person)
	person.number_scrap = 5
	
