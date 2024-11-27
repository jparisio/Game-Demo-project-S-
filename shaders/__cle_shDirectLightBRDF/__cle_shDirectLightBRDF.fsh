
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
uniform vec4 u_params1; // normalDistance, diffuse, specular, reflection
uniform sampler2D u_normalTex;
uniform sampler2D u_materialTex;
uniform sampler2D u_albedoTex;
uniform sampler2D u_reflectionTex;

#define EPSILON 0.0001
#define M_PI 3.1415926538

const vec3 viewDir = vec3(0.0, 0.0, 1.0);

#region BRDF GGX
const vec3 DIELECTRIC = vec3(0.04);
//#define BLUR_ROUGHNESS

// Shlick's approximation of the Fresnel factor.
vec3 fresnelSchlick(vec3 F0, float cosTheta) {
	return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

// GGX/Towbridge-Reitz normal distribution function.
// Uses Disney's reparametrization of alpha = roughness^2.
float ndfGGX(float NdotH, float roughness) {
	float alpha = roughness * roughness;
	float alphaSq = alpha * alpha;
	float denom = (NdotH * NdotH) * (alphaSq - 1.0) + 1.0;
	return alphaSq / (M_PI * denom * denom);
}

// Single term for separable Schlick-GGX below.
float gaSchlickG1(float cosTheta, float k) {
	return cosTheta / (cosTheta * (1.0 - k) + k);
}

// Schlick-GGX approximation of geometric attenuation function using Smith's method.
float gaSchlickGGX(float NdotV, float NdotL, float roughness) {
	float r = roughness + 1.0;
	float k = (r * r) / 8.0; // Epic suggests using this roughness remapping for analytic lights.
	return gaSchlickG1(NdotV, k) * gaSchlickG1(NdotL, k);
}

// Roughness blur
const float goldenAngle = 2.39996323;
vec3 blurReflection(sampler2D tex, vec2 uv, float amount) {
	vec2 radius = vec2(0.01) * amount;
	vec3 blur;
	float total;
	for(float i = 0.0; i < 64.0; i+=goldenAngle) {
		blur += texture2D(tex, uv + vec2(cos(i), sin(i)) * sqrt(i) * radius).rgb;
		total++;
	}
	blur /= total;
	return blur;
}
#endregion

void main() {
	// Material
	vec3 albedo = texture2D(u_albedoTex, v_vTexcoord).rgb;
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
	
	// PBR BRDF
	vec3 F0 = mix(DIELECTRIC, albedo, metallic);
	vec3 V = viewDir;
	vec3 H = normalize(V + L); // halfwayDir
	float NdotV = max(0.0, dot(N, V));
	float NdotH = max(0.0, dot(N, H));
	vec3 F = fresnelSchlick(F0, max(dot(H, V), 0.0));
	float D = ndfGGX(NdotH, roughness);
	float G = gaSchlickGGX(NdotV, NdotL, roughness);
	vec3 specularCT = (F * D * G) / max(4.0 * NdotV * NdotL, EPSILON); // cook-torrance specular microfacet brdf. numerator / denominator
	//vec3 kDiffuse = ((vec3(1.0) - F) * (1.0-metallic));
	
	// Diffuse
	//vec3 diffuse = u_params.z * lightAttenuation * ((v_vColour.rgb*u_params1.y) + ((kDiffuse*(albedo/M_PI)+specularCT)*v_vColour.rgb*u_params1.z));
	vec3 diffuse = u_params.z * lightAttenuation * ((v_vColour.rgb*u_params1.y) + (specularCT*v_vColour.rgb*u_params1.z)); // looks better..
	
	// Reflections
	vec2 reflectionUV = v_vTexcoord + (N.xy * roughness * u_params1.w);
	vec3 reflectionCol = texture2D(u_reflectionTex, reflectionUV).rgb;
	#ifdef BLUR_ROUGHNESS
    reflectionCol = blurReflection(u_reflectionTex, reflectionUV, roughness);
	#endif
    diffuse = mix(diffuse, mix(reflectionCol*diffuse, diffuse, roughness), metallic);
	
	gl_FragColor = vec4(diffuse, 1.0);
}
