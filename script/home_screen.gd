extends Node2D



func _on_button_pressed() -> void:
	GameData.number_rounds = $SpinBox.value
	get_tree().change_scene_to_file("res://scene/fight_arena1.tscn")
