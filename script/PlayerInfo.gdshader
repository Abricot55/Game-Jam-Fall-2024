shader_type canvas_item;

		void fragment() {
			vec4 tex_color = texture(TEXTURE, UV);
			// Convert to grayscale
			float gray = dot(tex_color.rgb, vec3(0.3, 0.59, 0.11));
			// Reduce opacity for "disabled" effect
			COLOR = vec4(vec3(gray), tex_color.a * 0.5);
		}