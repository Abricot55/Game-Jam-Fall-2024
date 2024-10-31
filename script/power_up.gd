extends Node3D

var which = 0


signal pick_up

func set_wich(num):
	var shield = $shield
	var speed = $speed
	var freeze = $freeze
	which = num % 3
	match which:
		0: 
			shield.visible = true
			speed.visible = false
			freeze.visible = false
		1:
			shield.visible = false
			speed.visible = true
			freeze.visible = false
		2:
			shield.visible = false
			speed.visible = false
			freeze.visible = true

func _process(delta: float):
	rotate_z(delta)


func _on_area_3d_area_entered(area: Area3D) -> void:
	emit_signal("pick_up")
