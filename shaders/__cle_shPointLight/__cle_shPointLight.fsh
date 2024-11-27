
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

#define EPSILON 0.0001

void main() {
	// Attenuation
	float lightDist = length(v_vPosition.xy - u_params.xy);
	float lightAttenuation = pow(smoothstep(0.0, 1.0-u_params2.y, (1.0-lightDist/u_params.z)), u_params2.z*2.0+EPSILON);
	lightAttenuation = floor(lightAttenuation * u_params2.w + 0.5) / u_params2.w;
	gl_FragColor = vec4(u_params2.x*vec3(lightAttenuation)*v_vColour.rgb, 1.0);
}
