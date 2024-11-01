extends Node3D

@onready var bank = $Bank
@onready var bank2 = $Bank2
@onready var bank3 = $Bank3
@onready var bank4 = $Bank4
@onready var player_infos = $PlayerInfo
@onready var timer = $Timer
@onready var debris_spawner = $DebrisSpawn

var player_scene = preload("res://scene/robot_3d.tscn")
var ai_bot_scene = preload("res://scene/aI_bot.tscn")
var final_scene = preload("res://scene/endScreen.tscn")
var power_up_scene = preload("res://scene/power_up.tscn")

var players = []
var colors = [Color(1,0,0),Color(0,1,0), Color(0,0,1), Color(1,1,0)]
var respawn_positions = [Vector3(-15, 30, -15), Vector3(15, 30, 15), Vector3(-15, 30, 15), Vector3(15, 30, -15)]
var gameTime = null

func _ready():
	get_child(1).team = 1
	get_child(2).team = 2
	get_child(3).team = 3
	GameData.banks = [bank, $Bank2, $Bank3, $Bank4]
	change_bank_color()
	check_if_bank_there()
	put_good_description()
	timer.start()
	player_infos.countdown.text = str(int(timer.time_left)+1)
	set_up_players()
	GameData.players = players
	if GameData.game_mode == "POOR" or GameData.game_mode == "CHRONO":
		gameTime = Timer.new()
		gameTime.wait_time = 100
		gameTime.one_shot = true
		gameTime.connect("timeout",Callable(self,"game_finished"))
		add_child(gameTime)
		gameTime.start()
	else : 
		player_infos.gameTime.visible = false
	var powertime = Timer.new()
	powertime.wait_time = 15
	powertime.connect("timeout",Callable(self,"make_power_up_appear"))
	add_child(powertime)
	powertime.start()

func set_up_players():
	var num_pl = 0
	var cmp = 0
	for i in GameData.selection_player:
		players.append(null)
		if i == "Joueur":
			var player = player_scene.instantiate()
			player.get_child(0).playernum = num_pl % 2
			print(player.get_child(0).playernum)
			num_pl+=1
			player.set_team(cmp)
			print(player.team)
			respawn(player, respawn_positions[cmp])
			player.get_child(0).connect("attack",  Callable(self, "_on_player_attacked").bind(cmp))
			player.get_child(0).connect("died",  Callable(self, "_died").bind(cmp))
			player.connect("scrap_changed", Callable(self, "changeLabel").bind(cmp))
			player.connect("died",  Callable(self, "_died").bind(cmp))
			player.get_child(0).connect("action", Callable(self, "_do_action").bind(cmp))
			player.get_child(0).get_child(player.team+2).visible = true
			player.process_mode = PROCESS_MODE_DISABLED
		elif i == "CPU":
			var new_ai_bot = ai_bot_scene.instantiate()
			new_ai_bot.team = cmp
			respawn(new_ai_bot,respawn_positions[new_ai_bot.team])
			new_ai_bot.connect("died", Callable(self,"_died").bind(new_ai_bot.team))
			new_ai_bot.get_child(0).connect("died", Callable(self,"_died").bind(new_ai_bot.team))
			new_ai_bot.get_child(0).connect("banked", Callable(self,"_put_in_bank").bind(new_ai_bot.team))
			new_ai_bot.connect("scrap_changed", Callable(self, "changeLabel").bind(new_ai_bot.team))
			new_ai_bot.get_child(0).connect("attack",  Callable(self, "_on_player_attacked").bind(new_ai_bot.team))
			new_ai_bot.get_child(0).get_child(new_ai_bot.team+2).visible = true
			new_ai_bot.process_mode = Node.PROCESS_MODE_DISABLED
		cmp += 1
	
func _process(_delta):
	if timer.is_stopped() == false:
		player_infos.countdown.text = str(int(timer.time_left)+1)
	if gameTime != null:
		player_infos.gameTime.text = str(int(gameTime.time_left))
	GameData.players = players

func _do_action(player_id):
	if GameData.game_mode == "BANK":
		for banki in GameData.banks:
			if players[player_id].get_child(0).global_transform.origin.distance_to(banki.global_transform.origin) < banki.scale.x+2 and banki.team == player_id:
				if players[player_id].get_num_scrap() > 1:
					players[player_id].remove_a_scrap()
					banki.add_scrap()
					player_infos.players_info[player_id].get_child(3).text = "Banked : "+ str(banki.number_scrap)
					if banki.number_scrap == 30:
						game_finished()
	elif GameData.game_mode == "POOR":
		for banki in GameData.banks:
			if players[player_id].get_child(0).global_transform.origin.distance_to(banki.global_transform.origin) < banki.scale.x+2 and banki.team != player_id:
				if players[player_id].get_num_scrap() > 1:
					players[player_id].remove_a_scrap()
					banki.add_scrap()
					player_infos.players_info[banki.team].get_child(3).text = "Banked : "+ str(banki.number_scrap)

func _on_player_attacked(player_id):
	if players[player_id] != null:
		for bot in players:
			if bot != null:
				if bot.team != player_id:
					if bot.realposition != null:
						if players[player_id].in_attack_area(bot.realposition):
							if players[player_id].att_freeze == true:
								bot.is_frozen()
								players[player_id].att_freeze = false
							bot.attacked()

func _died(player_id):
	var person = players[player_id]
	players[player_id] = null
	remove_child(person)
	GameData.players = players
	player_infos.players_info[person.team].material = GameData.shader_material
	await get_tree().create_timer(3.0).timeout # Wait for 3 seconds
	respawn(person)

func respawn(person, positionr = null): 
	if positionr == null:
		person.get_child(0).position = respawn_positions[randi() % respawn_positions.size()]
	else :
		person.get_child(0).position = positionr
	person.get_child(0).velocity = Vector3(0,0,0)
	players[person.team] = person
	add_child(person)
	person.number_scrap = 15
	changeLabel(person.team)
	GameData.players = players
	player_infos.players_info[person.team].material = null
	
func _put_in_bank(player_id):
	var which = null
	for i in GameData.banks:
		if players[player_id].get_child(0).bank_location == i.position:
			which = i
	which.add_scrap()
	players[player_id].remove_a_scrap()
	player_infos.players_info[which.team].get_child(3).text = "Banked : "+ str(which.number_scrap)
	if which.number_scrap == 30 and GameData.game_mode == "BANK":
		game_finished()

func _on_timer_timeout() -> void:
	player_infos.countdown.visible = false
	for i in players:
		if i != null:
			i.process_mode = Node.PROCESS_MODE_INHERIT

func changeLabel(player_id):
	if players[player_id] != null:
		player_infos.players_info[player_id].get_child(1).text = "Scraps : "+ str(players[player_id].number_scrap)
	

func change_bank_color():
	var bank2 = $Bank2
	var bank3 = $Bank3
	var bank4 = $Bank4
	bank.get_child(0).visible = true
	bank2.get_child(1).visible = true
	bank3.get_child(2).visible = true
	bank4.get_child(3).visible = true

func make_power_up_appear():
	var positions = [Vector3(-34.004,12.001,-2.595), Vector3(-2.743,5,21.549), Vector3(35.078,12.001,-4.036), Vector3(-1.024,12.001,-28.826) ]
	var power = power_up_scene.instantiate()
	power.set_wich(randi() % 3)
	power.position = positions[randi() % positions.size()]
	add_child(power)

func check_if_bank_there():
	if GameData.game_mode != "BANK" and GameData.game_mode != "POOR":
		remove_child(bank)
		remove_child(bank2)
		remove_child(bank3)
		remove_child(bank4)

func game_finished():
	if GameData.game_mode == "POOR":
		var cmp = 0
		for i in GameData.banks:
			GameData.points[cmp] += -i.number_scrap + 30
			cmp += 1
	if GameData.game_mode == "CHRONO":
		var cmp = 0
		for i in GameData.players:
			if i != null:
				GameData.points[cmp] += i.number_scrap
			cmp += 1
	if GameData.game_mode == "BANK":
		var cmp = 0
		for i in GameData.banks:
			GameData.points[cmp] += i.number_scrap
			cmp += 1
	GameData.next_game()
	
func put_good_description():
	match GameData.game_mode:
		"BANK" : 
			player_infos.get_child(2).text = "First with 30 scraps in the bank win!"
		"POOR" : 
			player_infos.get_child(2).text = "Least amount in bank at the end of the chrono wins!"
		"CHRONO" : 
			player_infos.get_child(2).text = "Most scraps at the end of the chrono wins!"
			player_infos.players_info[0].get_child(3).visible = false
			player_infos.players_info[1].get_child(3).visible = false
			player_infos.players_info[2].get_child(3).visible = false
			player_infos.players_info[3].get_child(3).visible = false
