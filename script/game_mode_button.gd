extends Button

# Enum pour les états
enum PlayerType {
	BANK,
	MIXTE,
	POOR,
	CHRONO
}

# Variable pour stocker l'état actuel
var current_type = PlayerType.BANK

func _ready():
	update_button_display()

func _on_Button_pressed():
	current_type = (current_type + 1) % 4 as PlayerType
	update_button_display()

func update_button_display():
	match current_type:
		PlayerType.BANK:
			text = "BANK"
		PlayerType.MIXTE:
			text = "MIXTE"
		PlayerType.POOR:
			text = "POOR"
		PlayerType.CHRONO:
			text = "CHRONO"
