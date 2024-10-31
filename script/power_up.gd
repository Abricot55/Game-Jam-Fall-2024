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
	var area_parent = area.get_parent() # could be characterbody3d
	if area_parent == null:
		return
	var second_parent = area_parent.get_parent() # could be robot or aibot
	if second_parent is Robot:
		make_power(second_parent)
		self.queue_free()
	elif second_parent is AIBot:
		make_power(second_parent)
		self.queue_free()
	emit_signal("pick_up")

func make_power(parent):
	match which:
		0: parent.activate_shield()
		1: parent.activate_super_speed()
		2: parent.activate_freeze()
		
func _on_body_entered(body: Node3D) -> void:
	body = body.get_parent()
	if body is Robot:
		make_power(body)
		self.queue_free()
