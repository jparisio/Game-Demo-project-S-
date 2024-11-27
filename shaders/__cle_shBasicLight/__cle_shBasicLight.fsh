
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_intensity;

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	gl_FragColor.rgb *= u_intensity;
}
