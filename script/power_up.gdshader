shader_type spatial;

uniform sampler2D texture_albedo;

void fragment() {
    // Coordonnées UV en fonction de la face avant (Z+)
    vec2 uv = FRAGCOORD.xy / vec2(1,1); // Remplacez BOX_SIZE_X/Y par la taille de votre boîte

    // Afficher la texture seulement sur la face avant
    if (NORMAL.z > 0.9) {
        ALBEDO = texture(texture_albedo, uv).rgb;
    } else {
        // Affiche une couleur neutre ou masque les autres faces
        ALBEDO = vec3(0.0);
    }
}
