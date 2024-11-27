
precision highp float;

// from ShadowCaster
attribute vec3 in_Colour; // positionXY, Width
attribute vec4 in_Colour2; // texCoordXY, localXY
attribute vec3 in_Colour3; // angle, lockRot

uniform vec3 u_params; // additionalAngle, shadowLength, width
varying vec2 v_vTexcoord;

void main() {
	// (C) 2024, Mozart Junior (@foxyofjungle) (https://foxyofjungle.itch.io/)
	float angle = (in_Colour3.x + u_params.x) * in_Colour3.y;
	float cosAngle = cos(angle);
	float sinAngle = sin(angle);
	mat2 rot = mat2(cosAngle, -sinAngle, sinAngle, cosAngle);
	
	vec2 size = in_Colour2.zw;
	size.x *= (in_Colour.z * u_params.z) * mix(dot(vec2(cosAngle, sinAngle), vec2(1.0, 0.0)), 1.0, in_Colour3.z);
	size.y *= u_params.y;
	vec2 shadowPos = in_Colour.xy + size * rot;
	
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(shadowPos, 0.0, 1.0);
	v_vTexcoord = in_Colour2.xy;
}
