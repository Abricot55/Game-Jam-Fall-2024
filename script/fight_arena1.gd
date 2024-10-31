extends Node3D

@onready var bank = $Bank
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


func _ready():
	get_child(1).team = 1
	get_child(2).team = 2
	get_child(3).team = 3
	GameData.banks = [bank, $Bank2, $Bank3, $Bank4]
	change_bank_color()
	timer.start()
	player_infos.countdown.text = str(int(timer.time_left)+1)
	set_up_players()
	GameData.players = players
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
	GameData.players = players

func _do_action(player_id):
	for banki in GameData.banks:
		if players[player_id].get_child(0).global_transform.origin.distance_to(banki.global_transform.origin) < banki.scale.x+2 and banki.team == player_id:
			if players[player_id].get_num_scrap() > 1:
				players[player_id].remove_a_scrap()
				banki.add_scrap()
				player_infos.players_info[player_id].get_child(3).text = "Banked : "+ str(banki.number_scrap)
				if banki.number_scrap == 30:
					var scene = final_scene.instantiate()
					scene.get_child(player_id).visible = true
					get_tree().get_root().add_child(scene)
					get_tree().current_scene.queue_free()
					
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
	person.number_scrap = 5
	changeLabel(person.team)
	GameData.players = players
	player_infos.players_info[person.team].material = null
	
func _put_in_bank(player_id):
	get_child(player_id).add_scrap()
	players[player_id].remove_a_scrap()
	player_infos.players_info[player_id].get_child(3).text = "Banked : "+ str(get_child(player_id).number_scrap)
	if get_child(player_id).number_scrap == 30:
		var scene = final_scene.instantiate()
		scene.get_child(player_id).visible = true
		get_tree().get_root().add_child(scene)
		get_tree().current_scene.queue_free()

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
