extends Button

# Enum pour les états
enum PlayerType {
	NONE,
	PLAYER,
	CPU
}

# Variable pour stocker l'état actuel
var current_type = PlayerType.NONE

func _ready():
	update_button_display()

func _on_Button_pressed():
	current_type = (current_type + 1) % 3 as PlayerType
	update_button_display()

func update_button_display():
	match current_type:
		PlayerType.NONE:
			text = "Aucun"
		PlayerType.PLAYER:
			text = "Joueur"
		PlayerType.CPU:
			text = "CPU"
