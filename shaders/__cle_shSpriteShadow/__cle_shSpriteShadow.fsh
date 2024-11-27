
varying vec2 v_vTexcoord;

void main() {
	gl_FragColor = vec4(0.0, 0.0, 0.0, texture2D(gm_BaseTexture, v_vTexcoord).a);
	//gl_FragColor = vec4(v_vTexcoord.x, v_vTexcoord.y, 0.0, 1.0);
}
