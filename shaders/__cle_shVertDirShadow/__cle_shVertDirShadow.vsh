
precision highp float;

// from ShadowCaster
attribute vec4 in_Colour; // positionXY, depth, farZ
attribute vec4 in_Colour2; // texCoordXY, shadowLength, penumbraOffset

// from light
uniform vec4 u_params; // shadowPenumbra, shadowUmbra, shadowScattering, shadowDepthOffset
uniform vec3 u_params2; // xDir, yDir, lightPenetration

varying vec2 v_vTexcoord;
varying float v_vFalloffUf;
varying float v_vFalloffPf;

void main() {
	// (C) 2024, Mozart Junior (@foxyofjungle) (https://foxyofjungle.itch.io/)
	// Inspired by Slembcke (https://slembcke.github.io/SuperFastSoftShadows)
	float shadowLen = u_params.z; //(100.*in_Colour2.z) + u_params.z;
	vec2 shadowPos = in_Colour.xy + (in_Colour.w * u_params2.xy + normalize(vec2(u_params2.y, -u_params2.x))*u_params.x*in_Colour2.w) * shadowLen;
	
	float projDist = length((in_Colour.xy+in_Colour.w) - in_Colour.xy); // proj - pos
	v_vFalloffUf = projDist * u_params.y;
	v_vFalloffPf = projDist / (u_params2.z / shadowLen);
	
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(shadowPos, in_Colour.z+u_params.w, 1.0);
	v_vTexcoord = in_Colour2.xy;
}
