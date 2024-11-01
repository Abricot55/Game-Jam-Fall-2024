extends Control



func _on_button_pressed() -> void:
	GameData.set_game_mode($VBoxContainer/HBoxContainer2/SpinBox.value,$VBoxContainer/HBoxContainer2/game_mode_button.text)
	var first = $VBoxContainer/HBoxContainer/choose1.text
	var second = $VBoxContainer/HBoxContainer/choose2.text
	var third = $VBoxContainer/HBoxContainer/choose3.text
	var fourth = $VBoxContainer/HBoxContainer/choose4.text
	
	GameData.selection_player.append(first)
	GameData.selection_player.append(second)
	GameData.selection_player.append(third)
	GameData.selection_player.append(fourth)
	get_tree().change_scene_to_file("res://scene/fight_arena1.tscn")
