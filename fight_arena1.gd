extends Node3D

@onready var robot1 = $Robot/CharacterBody3D
@onready var bank = $Bank

var ai_bot_scene = preload("res://scene/aI_bot.tscn")

var aiBot = []

func _ready():
	var new_ai_bot = ai_bot_scene.instantiate()  # Create an instance of the aiBot
	new_ai_bot.position = Vector3(2, 0, 0)  # Set a position for the bot (adjust as needed)
	add_child(new_ai_bot)
	aiBot.append(new_ai_bot)
	robot1.connect("attack", Callable(self, "_on_player_attacked").bind([robot1.get_team()]))
	

func _process(delta):
	if Input.is_action_just_pressed("z"):
		print(bank.scale.x)
		if robot1.global_transform.origin.distance_to(bank.global_transform.origin) < bank.scale.x+2:
			if robot1.get_num_scrap() > 1:
				robot1.remove_a_scrap()
				bank.add_scrap()

func _on_player_attacked(player_id):
	for bot in aiBot:
		if robot1.in_attack_area(bot.realposition):
			bot.attacked()
			print(bot.number_scrap)
			if bot.number_scrap <= 0:
				remove_child(bot)
				aiBot.erase(bot)


