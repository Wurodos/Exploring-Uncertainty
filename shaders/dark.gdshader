shader_type canvas_item;

void fragment() {
	float alpha = UV.x + (sin(TIME) + 1.) / 4.;
	COLOR = vec4(0,0,0,alpha);
}
