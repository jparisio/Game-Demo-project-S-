
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

precision highp float;

varying vec3 v_vPosition;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_params; // directionXY, intensity
uniform vec3 u_params1; // normalDistance, diffuse, specular
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
	vec3 lightDir = vec3(u_params.xy, u_params1.x);
	vec3 normalCol = texture2D(u_normalTex, v_vTexcoord).rgb;
	//#ifdef _YY_HLSL11_
	normalCol.y = 1.0-normalCol.y;
	//#endif
	vec3 N = normalize(normalCol * 2.0 - 1.0);
	vec3 L = normalize(lightDir);
	float NdotL = max(dot(N, L), 0.0);
	
	// Attenuation
	float lightAttenuation = NdotL;
	//lightAttenuation *= materialCol.a;
	
	// Specular
	float glossiness = (1.0 / (1.0-roughness));
	float kEnergyConservation = (2.0 + glossiness) / M_TAU;
	float specular = pow(max(dot(N, normalize(L-viewDir)), 0.0), glossiness+EPSILON) * kEnergyConservation;
	
	// Diffuse + Specular
	gl_FragColor = vec4(u_params.z * lightAttenuation * ((v_vColour.rgb*u_params1.y) + (specular*v_vColour.rgb*u_params1.z)), 1.0);
}
