extends AudioStreamPlayer

func _ready():
	play()  # Start the sound when the scene loads
	set_autoplay(true)  # Ensures autoplay

func _process(delta):
	if !is_playing():
		play()  # Restart the sound if it has finished playing
