extends Control



func _on_button_pressed() -> void:
	GameData.number_rounds = $VBoxContainer/HBoxContainer2/SpinBox.value
	get_tree().change_scene_to_file("res://scene/fight_arena1.tscn")
