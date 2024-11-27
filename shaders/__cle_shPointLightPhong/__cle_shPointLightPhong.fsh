
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

uniform vec3 u_params; // x, y, radius
uniform vec4 u_params2; // intensity, inner, falloff, levels
uniform vec3 u_params3; // normalDistance, diffuse, specular
uniform sampler2D u_normalTex;
uniform sampler2D u_materialTex;

#define EPSILON 0.0001
#define M_TAU 6.2831853076

const vec3 viewDir = vec3(0.0, 0.0, 1.0); // eyeDir

void main() {
	// Material
	vec4 materialCol = texture2D(u_materialTex, v_vTexcoord); // Metallic (R), Roughness (G), Mask (A)
	float metallic = materialCol.r;
	float roughness = materialCol.g; // 0 = full reflective (only if metallic > 0)
	
	// Normal
	vec3 lightDir = vec3(u_params.xy - v_vPosition.xy, u_params3.x);
	vec3 normalCol = texture2D(u_normalTex, v_vTexcoord).rgb;
	//#ifdef _YY_HLSL11_
	normalCol.y = 1.0-normalCol.y;
	//#endif
	vec3 N = normalize(normalCol * 2.0 - 1.0);
	vec3 L = normalize(lightDir);
	float NdotL = max(dot(N, L), 0.0);
	
	// Attenuation
	float lightDist = length(v_vPosition.xy - u_params.xy);
	float lightAttenuation = pow(smoothstep(0.0, 1.0-u_params2.y, (1.0-lightDist/u_params.z)*NdotL), u_params2.z*2.0+EPSILON);
	lightAttenuation = floor(lightAttenuation * u_params2.w + 0.5) / u_params2.w;
	//lightAttenuation *= materialCol.a; // mask
	
	// Specular. normalize(L-viewDir) is halfwayDir (H)
	float glossiness = (1.0 / (1.0-roughness));
	float kEnergyConservation = (2.0 + glossiness) / M_TAU;
	float specular = pow(max(dot(N, normalize(L-viewDir)), 0.0), glossiness+EPSILON) * kEnergyConservation;
	
	// Diffuse + Specular
	gl_FragColor = vec4(u_params2.x * lightAttenuation * ((v_vColour.rgb*u_params3.y) + (specular*v_vColour.rgb*u_params3.z)), 1.0);
}
