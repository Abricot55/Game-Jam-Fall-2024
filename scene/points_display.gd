extends Control

func _ready() -> void:
	$VBoxContainer/pointred.text = "Player 1 : " + str(GameData.points[0])
	$VBoxContainer/pointblue.text = "Player 2 : " + str(GameData.points[1])
	$VBoxContainer/pointyellow.text = "Player 3 : " + str(GameData.points[2])
	$VBoxContainer/pointgreen.text = "Player 4 : " + str(GameData.points[3])
	
