extends Node3D

@onready var bank = $Bank
@onready var player_infos = $PlayerInfo
@onready var timer = $Timer
@onready var debris_spawner = $DebrisSpawn

var player_scene = preload("res://scene/robot_3d.tscn")
var ai_bot_scene = preload("res://scene/aI_bot.tscn")
var final_scene = preload("res://scene/endScreen.tscn")

var players = []
var colors = [Color(1,0,0),Color(0,1,0), Color(0,0,1), Color(1,1,0)]
var respawn_positions = [Vector3(-15, 30, -15), Vector3(15, 30, 15), Vector3(-15, 30, 15), Vector3(15, 30, -15)]


func _ready():
	get_child(1).team = 1
	get_child(2).team = 2
	get_child(3).team = 3
	GameData.banks = [bank, $Bank2, $Bank3, $Bank4]
	for i in range(GameData.num_bot + GameData.num_player):
		players.append(null)
	timer.start()
	player_infos.countdown.text = str(int(timer.time_left)+1)
	for i in range(0,GameData.num_player):
		var player = player_scene.instantiate()
		player.set_team(i)
		respawn(player, respawn_positions[i])
		player.get_child(0).connect("attack",  Callable(self, "_on_player_attacked").bind(i))
		player.get_child(0).connect("died",  Callable(self, "_died").bind(i))
		player.connect("scrap_changed", Callable(self, "changeLabel").bind(i))
		player.connect("died",  Callable(self, "_died").bind(i))
		player.get_child(0).get_child(2).get_active_material(0).albedo_color = colors[player.team]
		player.process_mode = PROCESS_MODE_DISABLED
		
	for i in range(0,GameData.num_bot):
		var new_ai_bot = ai_bot_scene.instantiate()
		new_ai_bot.team = i + GameData.num_player
		respawn(new_ai_bot,respawn_positions[new_ai_bot.team])
		print(new_ai_bot.get_child(0).get_child(2).get_active_material(0))
		new_ai_bot.connect("died", Callable(self,"_died").bind(new_ai_bot.team))
		new_ai_bot.get_child(0).connect("died", Callable(self,"_died").bind(new_ai_bot.team))
		new_ai_bot.get_child(0).connect("banked", Callable(self,"_put_in_bank").bind(new_ai_bot.team))
		new_ai_bot.connect("scrap_changed", Callable(self, "changeLabel").bind(new_ai_bot.team))
		new_ai_bot.get_child(0).connect("attack",  Callable(self, "_on_player_attacked").bind(new_ai_bot.team))
		new_ai_bot.get_child(0).get_child(new_ai_bot.team+1).visible = true
		new_ai_bot.process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta):
	if timer.is_stopped() == false:
		player_infos.countdown.text = str(int(timer.time_left)+1)

	if Input.is_action_just_pressed("z"):
		if players[0].get_child(0).global_transform.origin.distance_to(bank.global_transform.origin) < bank.scale.x+2 :
			if players[0].get_num_scrap() > 1:
				players[0].remove_a_scrap()
				bank.add_scrap()
				player_infos.players_info[0].get_child(3).text = "Banked : "+ str(bank.number_scrap)
				if bank.number_scrap == 30:
					var scene = final_scene.instantiate()
					scene.get_child(0).visible = true
					get_tree().get_root().add_child(scene)
					get_tree().current_scene.queue_free()
	GameData.players = players

func _on_player_attacked(player_id):
	for bot in players:
		if bot != null:
			if bot.team != player_id:
				if bot.realposition != null:
					if players[player_id].in_attack_area(bot.realposition):
						bot.attacked()

func _died(player_id):
	var person = players[player_id]
	players[player_id] = null
	remove_child(person)
	await get_tree().create_timer(3.0).timeout # Wait for 3 seconds
	respawn(person)

func respawn(person, position = null): 
	if position == null:
		person.get_child(0).position = respawn_positions[randi() % respawn_positions.size()]
	else :
		person.get_child(0).position = position
	person.get_child(0).velocity = Vector3(0,0,0)
	players[person.team] = person
	add_child(person)
	person.number_scrap = 5
	changeLabel(person.team)
	
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
		i.process_mode = Node.PROCESS_MODE_INHERIT

func changeLabel(player_id):
	if players[player_id] != null:
		player_infos.players_info[player_id].get_child(1).text = "Scraps : "+ str(players[player_id].number_scrap)
	
