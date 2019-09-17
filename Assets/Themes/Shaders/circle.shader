shader_type canvas_item;

void fragment (){
	COLOR = vec4(texture(TEXTURE,UV).rgb, 1.0- 50.0*(clamp(distance(UV,vec2(0.5,0.5)),0.47,0.49)-0.47));
}

