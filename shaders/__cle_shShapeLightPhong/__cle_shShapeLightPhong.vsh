
attribute vec3 in_Position; // (x,y,z)
attribute vec4 in_Colour; // (r,g,b,a)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vPosition;
varying mat2 v_vRotationMatrix;

uniform float u_params; // angle

void main() {
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.xyz, 1.0);
	// get UV from NDC and normalize it
	v_vTexcoord = (gl_Position.xy / gl_Position.w)*0.5+0.5;
	#ifdef _YY_HLSL11_
	v_vTexcoord.y = 1.0-v_vTexcoord.y;
	#endif
	v_vPosition = in_Position.xyz;
	v_vColour = in_Colour;
	float angle = radians(u_params);
	float cosAngle = cos(angle);
	float sinAngle = sin(angle);
	v_vRotationMatrix = mat2(
		cosAngle, -sinAngle,
		sinAngle, cosAngle
	);
}
