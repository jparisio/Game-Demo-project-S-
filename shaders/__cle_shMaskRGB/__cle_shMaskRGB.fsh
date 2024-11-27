
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_materialTex;

void main() {
	vec4 col = texture2D(u_materialTex, v_vTexcoord);
	if (col.a < 0.5) discard;
	gl_FragColor = vec4(vec3(0.0), col.a);
}
