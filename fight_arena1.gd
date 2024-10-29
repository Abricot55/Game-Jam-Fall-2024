extends Node3D

@onready var bank = $Bank
@onready var player_infos = $PlayerInfo


var player_scene = preload("res://scene/robot_3d.tscn")
var ai_bot_scene = preload("res://scene/aI_bot.tscn")

var aiBot = []
var players = []
var gamemode = "BANK"
var numberplayer = 1
var colors = [Color(1,0,0),Color(0,1,0), Color(0,0,1), Color(1,1,0)]

func _ready():
	for i in range(0,4-numberplayer):
		var new_ai_bot = ai_bot_scene.instantiate()
		new_ai_bot.position = Vector3(2, 0, 0)  # Set a position for the bot (adjust as needed)
		add_child(new_ai_bot)
		new_ai_bot.team = i + numberplayer
		aiBot.append(new_ai_bot)
		print(new_ai_bot.get_child(0).get_child(2).get_active_material(0))
		new_ai_bot.connect("died", Callable(self,"_died").bind(new_ai_bot.team))
		new_ai_bot.get_child(0).get_child(new_ai_bot.team+1).visible = true
		
	for i in range(0,numberplayer):
		var player = player_scene.instantiate()
		var real_player = player.get_child(0)
		real_player.set_team(i)
		add_child(player)
		players.append(real_player)
		real_player.connect("attack",  Callable(self, "_on_player_attacked").bind([i]))
		real_player.get_child(2).get_active_material(0).albedo_color = colors[real_player.team]

func _process(delta):
	if Input.is_action_just_pressed("z"):
		if players[0].global_transform.origin.distance_to(bank.global_transform.origin) < bank.scale.x+2:
			if players[0].get_num_scrap() > 1:
				players[0].remove_a_scrap()
				bank.add_scrap()
				player_infos.get_child(0).get_child(1).text = "scraps : "+ str(bank.number_scrap) 

func _on_player_attacked(player_id):
	for bot in aiBot:
		if players[0].in_attack_area(bot.realposition):
			bot.attacked()

func _died(player_id):
	var person
	if player_id >= numberplayer:
		person = aiBot[player_id-numberplayer]
		aiBot.erase(person)
	else:
		person = players[player_id]
		players.erase(person)
	remove_child(person)
