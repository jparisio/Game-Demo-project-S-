
attribute vec3 in_Position; // (x,y,z)
attribute vec4 in_Colour; // (r,g,b,a)
attribute vec2 in_TextureCoord; // (u,v)

uniform float u_angle;
uniform vec2 u_scale;

varying mat2 v_vRotationMatrix;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	// Copyright (C) 2024, Mozart Junior (FoxyOfJungle)
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
	float angle = radians(u_angle);
	float cosAngle = cos(angle);
	float sinAngle = sin(angle);
	vec2 scale = sign(u_scale);
	v_vRotationMatrix = mat2(
		cosAngle*scale.x, -sinAngle*scale.y,
		sinAngle*scale.x, cosAngle*scale.y
	);
	v_vColour = in_Colour;
	v_vTexcoord = in_TextureCoord;
}
