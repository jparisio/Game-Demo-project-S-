
precision highp float;

varying vec2 v_vTexcoord;
varying float v_vFalloffUf;
varying float v_vFalloffPf;

void main() {
	gl_FragColor = vec4(0.0, 0.0, 0.0, smoothstep(0.0, 1.0, v_vTexcoord.x/v_vTexcoord.y) * smoothstep(1.0, 0.0, v_vFalloffUf) * smoothstep(0.0, 1.0, v_vFalloffPf));
}
