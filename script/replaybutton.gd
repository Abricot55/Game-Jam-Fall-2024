extends Button

var scene_to_load = "res://scene/homeScreen.tscn"

func _ready():
	self.connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	get_tree().current_scene.queue_free()
	get_tree().change_scene_to_file(scene_to_load)
