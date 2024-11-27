
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_alphaBlend;

void main() {
	vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor.rgb = col.rgb;
	gl_FragColor.a = mix(1.0, col.a, u_alphaBlend);
}
