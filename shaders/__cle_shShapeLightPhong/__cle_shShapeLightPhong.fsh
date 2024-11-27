
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

// known issue: rotation makes the normal map not work as expected
// this is expected because matrix_world rotates the vertices, but not desired
precision highp float;

varying vec3 v_vPosition;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat2 v_vRotationMatrix;

uniform vec4 u_params2; // intensity, inner, falloff, levels
uniform vec3 u_params3; // normalDistance, diffuse, specular
uniform sampler2D u_normalTex;
uniform sampler2D u_materialTex;

#define EPSILON 0.0001
#define M_TAU 6.2831853076

const vec3 viewDir = vec3(0.0, 0.0, 1.0);

void main() {
	// Material
	vec4 materialCol = texture2D(u_materialTex, v_vTexcoord);
	float metallic = materialCol.r;
	float roughness = materialCol.g;
	
	// Normal
	vec3 lightDir = vec3(-v_vPosition.xy, u_params3.x);
	vec3 normalCol = texture2D(u_normalTex, v_vTexcoord).rgb;
	//#ifdef _YY_HLSL11_
	normalCol.y = 1.0-normalCol.y;
	//#endif
	vec3 N = normalize(normalCol * 2.0 - 1.0);
	N.xy *= v_vRotationMatrix;
	vec3 L = normalize(lightDir);
	float NdotL = max(dot(N, L), 0.0);
	
	// Attenuation
	float lightAttenuation = pow(smoothstep(0.0, 1.0-u_params2.y, v_vColour.a*NdotL), u_params2.z*2.0+EPSILON);
	lightAttenuation = floor(lightAttenuation * u_params2.w + 0.5) / u_params2.w;
	
	// Specular
	float glossiness = (1.0 / (1.0-roughness));
	float kEnergyConservation = (2.0 + glossiness) / M_TAU;
	float specular = pow(max(dot(N, normalize(L-viewDir)), 0.0), glossiness+EPSILON) * kEnergyConservation;
	
	// Diffuse + Specular
	gl_FragColor = vec4(u_params2.x * lightAttenuation * ((v_vColour.rgb*u_params3.y) + (specular*v_vColour.rgb*u_params3.z)), 1.0);
}
