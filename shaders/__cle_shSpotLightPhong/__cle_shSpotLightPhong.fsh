
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
uniform vec4 u_params3; // spotDirectionXYZ, width
uniform vec3 u_params4; // spotFOV, spotSmoothness, spotDistance
uniform vec3 u_params5; // normalDistance, diffuse, specular
uniform vec4 u_cookieAtlasUVrect; //vec4(0.0, 0.0, 1.0, 1.0);
uniform sampler2D u_cookieTexture;
uniform sampler2D u_normalTex;
uniform sampler2D u_materialTex;

#define EPSILON 0.0001
#define M_PI 3.1415926538
#define M_TAU 6.2831853076

const vec3 viewDir = vec3(0.0, 0.0, 1.0);

void main() {
	vec3 lightPos = vec3(u_params.xy, u_params4.z);
	
	// Line
	if (u_params3.w > 0.0) {
		vec2 direction = vec2(-u_params3.y, u_params3.x) * u_params3.w;
		float projection = clamp(dot(v_vPosition.xy-lightPos.xy, direction) / dot(direction, direction), -1.0, 1.0);
		lightPos.xy += projection * direction;
	}
	
	// Material
	vec4 materialCol = texture2D(u_materialTex, v_vTexcoord);
	float metallic = materialCol.r;
	float roughness = materialCol.g;
	
	// Normal
	vec3 normalCol = texture2D(u_normalTex, v_vTexcoord).rgb;
	//#ifdef _YY_HLSL11_
	normalCol.y = 1.0-normalCol.y;
	//#endif
	vec3 N = normalize(normalCol * 2.0 - 1.0);
	vec3 L = normalize(-vec3(u_params3.xy, u_params3.z*u_params5.x)); //vec3(-lightDir.xy, u_params5.x)
	float NdotL = max(dot(N, L), 0.0);
	
	// Attenuation
	float lightDist = length(v_vPosition.xy-lightPos.xy);
	float lightAttenuation = smoothstep(0.0, 1.0-u_params2.y, (1.0-lightDist/u_params.z)*NdotL); // circ
	float halfFov = u_params4.x * 0.5;
	if (halfFov < M_PI) { // && halfFov > 0.0
		vec3 lightDir = vec3(v_vPosition.xy, 0.0) - lightPos;
		float cosSpotAngle = cos(halfFov);
		float cosAngle = dot(normalize(lightDir), u_params3.xyz);
		//lightAttenuation *= step(cosSpotAngle, cosAngle);
		lightAttenuation *= smoothstep(1.0, 1.0-u_params4.y, max((1.0-max(cosAngle, cosSpotAngle))/(1.0-cosSpotAngle), EPSILON));
		
		// cookie
		vec3 xAxis = normalize(cross(viewDir, u_params3.xyz));
		vec3 yAxis = normalize(cross(xAxis, u_params3.xyz));
		vec3 lightSpacePos;
		lightSpacePos.x = dot(lightDir, xAxis);
		lightSpacePos.y = dot(lightDir, yAxis);
		lightSpacePos.z = dot(lightDir, u_params3.xyz) * tan(clamp(halfFov, EPSILON, M_PI*0.5));
		vec2 cookieUV = clamp((lightSpacePos.xy/lightSpacePos.z)*0.5+0.5, 0.0, 1.0);
		lightAttenuation *= texture2D(u_cookieTexture, mix(u_cookieAtlasUVrect.xy, u_cookieAtlasUVrect.zw, cookieUV)).r;
	}
	lightAttenuation = pow(lightAttenuation, u_params2.z*2.0+EPSILON);
	lightAttenuation = floor(lightAttenuation * u_params2.w + 0.5) / u_params2.w;
	
	// Specular
	float glossiness = (1.0 / (1.0-roughness));
	float kEnergyConservation = (2.0 + glossiness) / M_TAU;
	float specular = pow(max(dot(N, normalize(L-viewDir)), 0.0), glossiness+EPSILON) * kEnergyConservation;
	
	// Diffuse + Specular
	gl_FragColor = vec4(u_params2.x * lightAttenuation * ((v_vColour.rgb*u_params5.y) + (specular*v_vColour.rgb*u_params5.z)), 1.0);
}
