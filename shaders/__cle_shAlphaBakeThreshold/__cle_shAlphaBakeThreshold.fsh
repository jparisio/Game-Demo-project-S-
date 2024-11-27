
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_color;
uniform float u_threshold;

void main() {
	vec4 col = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	col.a *= step(u_threshold, length(col.rgb-u_color));
	gl_FragColor = col;
}
