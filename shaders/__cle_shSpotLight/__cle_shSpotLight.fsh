
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

precision highp float;

varying vec3 v_vPosition;
varying vec4 v_vColour;
uniform vec3 u_params; // x, y, radius
uniform vec4 u_params2; // intensity, inner, falloff, levels
uniform vec4 u_params3; // spotDirectionXYZ, width
uniform vec3 u_params4; // spotFOV, spotSmoothness, spotDistance

#define EPSILON 0.0001
#define M_PI 3.1415926538
#define M_TAU 6.2831853076

void main() {
	vec3 lightPos = vec3(u_params.xy, u_params4.z);
	
	// Line
	if (u_params3.w > 0.0) {
		vec2 direction = vec2(-u_params3.y, u_params3.x) * u_params3.w;
		float projection = clamp(dot(v_vPosition.xy-lightPos.xy, direction) / dot(direction, direction), -1.0, 1.0);
		lightPos.xy += projection * direction;
	}
	
	float lightDist = length(v_vPosition.xy-lightPos.xy);
	float lightAttenuation = smoothstep(0.0, 1.0-u_params2.y, (1.0-lightDist/u_params.z));
	float halfFov = u_params4.x * 0.5;
	if (halfFov < M_PI) {
		float cosSpotAngle = cos(halfFov);
		float cosAngle = dot(normalize(vec3(v_vPosition.xy, 0.0)-lightPos), u_params3.xyz);
		//lightAttenuation *= step(cosSpotAngle, cosAngle);
		lightAttenuation *= smoothstep(1.0, 1.0-u_params4.y, max((1.0-max(cosAngle, cosSpotAngle))/(1.0-cosSpotAngle), EPSILON));
	}
	lightAttenuation = pow(lightAttenuation, u_params2.z*2.0+EPSILON) * u_params2.x;
	lightAttenuation = floor(lightAttenuation * u_params2.w + 0.5) / u_params2.w;
	
	gl_FragColor = vec4(vec3(lightAttenuation)*v_vColour.rgb, 1.0);
}
