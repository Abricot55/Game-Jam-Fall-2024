extends Node

var number_rounds = []
var game_mode = "BANK"
var selection_player = []
var players = []
var points = [0,0,0,0]
var banks = []
var shader_material
var shader_code = """
		shader_type canvas_item;

		void fragment() {
			vec4 tex_color = texture(TEXTURE, UV);
			// Convert to grayscale
			float gray = dot(tex_color.rgb, vec3(0.3, 0.59, 0.11));
			// Reduce opacity for "disabled" effect
			COLOR = vec4(vec3(gray), tex_color.a * 0.5);
		}
	"""

func _ready():
	var shader = Shader.new()
	shader.code = shader_code
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader

func next_game():
	number_rounds.pop_front()
	print(points)
	if number_rounds.size() == 0:
		get_tree().change_scene_to_file("res://scene/pointsDisplay.tscn")
		await get_tree().create_timer(3).timeout
		remove_all_nodes()
		var end = preload("res://scene/endScreen.tscn")
		end = end.instantiate()
		var max = 0
		var who = 0
		for i in range(points.size()):
			if points[i] != null and points[i] > max:
				max = points[i]
				who = i
		end.get_child(who).visible = true
		get_tree().get_root().add_child(end)
	else:
		game_mode = number_rounds[0]
		get_tree().change_scene_to_file("res://scene/pointsDisplay.tscn")
		await get_tree().create_timer(4).timeout
		get_tree().change_scene_to_file("res://scene/fight_arena1.tscn")
		
func set_game_mode(number, style):
	if style == "MIXTE":
		number_rounds = ["BANK", "CHRONO", "POOR"]
		game_mode = number_rounds[0]
	else:
		for i in range(number):
			number_rounds.append(style)
		game_mode = number_rounds[0]

func remove_all_nodes():
	var root = get_tree().root
	for child in root.get_children():
		child.queue_free()
